# ============================================================
# sweetdream:equipment/bow/bone_breaker/shot —— 每次射击(碎骨)
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:equipment/bow/bone_breaker(触发器 shot_crossbow)。
# 【文案】魔力 60。每次射击若场上没有「碎刀」，则召唤「碎刀」。
#   「碎刀」= 3 把旋转刀刃，刀刃每刻碰到生物时都会对其造成相当于自身基础攻击力
#   ×0.3 的伤害; 「碎刀」跟着自身准星移动，持续 8 秒。
# 【★ 三个口径 ★】
#   ① 「场上没有」= **自己**场上没有(别人的碎刀不算) ⇒ 认 zx.bb_own = 自己的 u0。
#      已经有三把在转的时候再射，只扣蓝、不重复召唤(也不刷新时长 —— 文案没写刷新)。
#   ② 伤害 = **基础攻击力**(manacore stats/base_attack, 不含手持) ×0.3，
#      召唤时算一次，之后每 20 刻跟着面板重算一次(会吃 buff / 换装备)。
#   ③ 「跟着准星移动」= 每刻把刀刃 tp 到**主人视线的本地坐标**上：
#      `at @a[...] anchored eyes run tp @s ^x ^y ^3.5`。
#      ★ 本地坐标的 x/y 是"视线的右/上"，所以在 x/y 上转圈 = 绕视线轴转(准星前自转)，
#        抬头低头都跟着走，而且**不需要任何三角函数**——位置是 24 档查表写死的。
# 【★ 无敌帧(2026-10-25 用户拍板) ★】本包伤害已改回吃原版受伤无敌帧(0.5 秒)，
#   于是"每刻碰到"实际表现为**同一目标每 0.5 秒吃一次**。这是期望行为, 不是丢伤害:
#   文案写的是"碰到就造成伤害"，引擎自己会把过密的命中吃掉，正好当作节流。
#   假如哪天要把"每刻都真打一次"找回来，只能另注册伤害类型挂 bypasses_cooldown。
# ============================================================

advancement revoke @s only sweetdream:equipment/bow/bone_breaker
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# ① 扣魔力 60
execute store result storage zx:work bbk.u0 int 1 run scoreboard players get @s manacore.u0
execute store result storage zx:work bbk.u1 int 1 run scoreboard players get @s manacore.u1
execute store result storage zx:work bbk.u2 int 1 run scoreboard players get @s manacore.u2
execute store result storage zx:work bbk.u3 int 1 run scoreboard players get @s manacore.u3
data modify storage zx:work bbk.uid set from storage zx:data self.uuid

# ③ 自己场上有没有碎刀? —— 用 u0 比对, 不认别人的
#   ★ 计分项比较没法直接拿实体分数和 storage 比 ⇒ 先搬进 #bb_u0(老套路)。
execute store result score #bb_u0 zx.meta run data get storage zx:work bbk.u0
scoreboard players set #bb_have zx.meta 0
function sweetdream:equipment/bow/bone_breaker/have with storage zx:work bbk
execute if score #bb_have zx.meta matches 1 run tellraw @s [{"text":"碎刀还在场上 —— 这一发不会重复召唤","color":"gray"}]
execute if score #bb_have zx.meta matches 1 run return 0
data modify storage manacore:in arg set value {uuid:"",value:60.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function sweetdream:lib/mana/pay
execute if data storage manacore:out r{success:0b} run tellraw @s [{"text":"魔力不足 —— 这一箭召不出碎刀","color":"red"}]
execute if data storage manacore:out r{success:0b} run return fail

# ② 自己的 UUID 四个整数 + 文本(文本给"每 20 刻重算伤害"用)

# ④ 伤害 = 基础攻击力 ×0.3(存 ×1000 的整数, 召唤时算一次)
#   ★ 基础攻击力一律走 manacore stats/get 的 base_attack(不含手持 —— MEMORY 环境段)。
#     `data get ... 1000` 会把 double 乘 1000 再取整, 足够这一档的精度。
function sweetdream:equipment/bow/bone_breaker/recalc

# ⑤ 三把刀, 起始角各差 120°(24 档制 ⇒ 0 / 8 / 16)
data modify storage zx:work bbk.a set value 0
execute at @s anchored eyes positioned ^ ^ ^3.5 run function sweetdream:equipment/bow/bone_breaker/blade_new with storage zx:work bbk
data modify storage zx:work bbk.a set value 8
execute at @s anchored eyes positioned ^ ^ ^3.5 run function sweetdream:equipment/bow/bone_breaker/blade_new with storage zx:work bbk
data modify storage zx:work bbk.a set value 16
execute at @s anchored eyes positioned ^ ^ ^3.5 run function sweetdream:equipment/bow/bone_breaker/blade_new with storage zx:work bbk

# ⑥ 表现
execute at @s run playsound minecraft:item.crossbow.shoot player @a ~ ~ ~ 0.6 1.1
execute at @s anchored eyes positioned ^ ^ ^3.5 run particle minecraft:sweep_attack ~ ~ ~ 0.9 0.9 0.9 0.0 6 normal

# ⑦ 「启示录」记页(与其余弩同款; 本件固定消耗 60 < 100, 不会产生页, 但接口要留着)
function sweetdream:equipment/staff/apocalypse/spend
