# ============================================================
# fallendream:equipment/bow/bone_breaker/shot —— 每次射击(碎骨)
# ------------------------------------------------------------
# 【谁调用它】进度 fallendream:equipment/bow/bone_breaker(触发器 shot_crossbow)。
# 【文案·原版】魔力 60。每次射击若场上没有「碎刀」，则召唤「碎刀」。
#   「碎刀」= 3 把旋转刀刃，刀刃每刻碰到生物时都会对其造成相当于自身基础攻击力
#   ×0.3 的伤害; 「碎刀」跟着自身准星移动，持续 8 秒。
# 【文案·超限】魔力 130；刀刃伤害 ×0.5；持续 10 秒；
#   · 同一生物每累计受到 6 次碎刀伤害 -> 额外 基础攻击力 ×3 真实伤害 + 2 秒缓慢Ⅲ + 附加「噬心」
#   · 碎刀持续期间再次射击 -> 刀刃 +1 且持续时间重置，每个碎刀最多触发 2 次
# 【★ 三个口径 ★】
#   ① 「场上没有」= **自己**场上没有(别人的碎刀不算) ⇒ 认 zx.bb_own = 自己的 u0。
#      已经有三把在转的时候再射:
#        · 原版 -> 只提示、不扣蓝、不重复召唤(也不刷新时长 —— 文案没写刷新);
#        · 超限 -> 追加一把、重置全部刀刃时长(见 again), 文案同样没写要扣魔力 ⇒ 不扣。
#   ② 伤害 = **基础攻击力**(manacore stats/base_attack, 不含手持) ×0.3 / ×0.5，
#      召唤时算一次，之后每 20 刻跟着面板重算一次(会吃 buff / 换装备)。
#   ③ 「跟着准星移动」= 每刻把刀刃 tp 到**主人视线的本地坐标**上：
#      `at @a[...] anchored eyes run tp @s ^x ^y ^3.5`。
#      ★ 本地坐标的 x/y 是"视线的右/上"，所以在 x/y 上转圈 = 绕视线轴转(准星前自转)，
#        抬头低头都跟着走，而且**不需要任何三角函数**——位置是 24 档查表写死的。
# 【★ 无敌帧(2026-10-25 用户拍板) ★】本包伤害已改回吃原版受伤无敌帧(0.5 秒)，
#   于是"每刻碰到"实际表现为**同一目标每 0.5 秒吃一次**。这是期望行为, 不是丢伤害:
#   文案写的是"碰到就造成伤害"，引擎自己会把过密的命中吃掉，正好当作节流。
#   超限的"累计 6 次"因此也是按**真正打出去的那几次**计数(见 blade_hit)。
# ============================================================

advancement revoke @s only fallendream:equipment/bow/bone_breaker
function fallendream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# ⓪ 这一箭是普通弩还是超限弩(快照在射手身上 —— again / 刀刃都由它分档)
scoreboard players set @s zx.bb_ol 0
execute if items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["bone_breaker"],ol:"bone_breaker"}] run scoreboard players set @s zx.bb_ol 1

# ① 自己的 UUID 四个整数 + 文本(文本给"每 20 刻重算伤害"用)
execute store result storage zx:work bbk.u0 int 1 run scoreboard players get @s manacore.u0
execute store result storage zx:work bbk.u1 int 1 run scoreboard players get @s manacore.u1
execute store result storage zx:work bbk.u2 int 1 run scoreboard players get @s manacore.u2
execute store result storage zx:work bbk.u3 int 1 run scoreboard players get @s manacore.u3
data modify storage zx:work bbk.uid set from storage zx:data self.uuid

# ② 档位也写进 bbk —— blade_new / again 从 storage 读, 不占宏参数
data modify storage zx:work bbk.ol set value 0
execute if score @s zx.bb_ol matches 1 run data modify storage zx:work bbk.ol set value 1

# ③ 自己场上有没有碎刀? —— 用 u0 比对, 不认别人的
#   ★ 计分项比较没法直接拿实体分数和 storage 比 ⇒ 先搬进 #bb_u0(老套路)。
execute store result score #bb_u0 zx.meta run data get storage zx:work bbk.u0
scoreboard players set #bb_have zx.meta 0
function fallendream:equipment/bow/bone_breaker/have with storage zx:work bbk
#   有碎刀 -> 交给 again 分档(原版只提示 / 超限追加一把), 之后这一发到此为止
execute if score #bb_have zx.meta matches 1 run function fallendream:equipment/bow/bone_breaker/again with storage zx:work bbk
execute if score #bb_have zx.meta matches 1 run return 0

# ④ 召唤: 追加计数从 0 开始(这是**新的一组**碎刀)
scoreboard players set @s zx.bb_add 0

# ⑤ 扣魔力: 原版 60 / 超限 130
data modify storage manacore:in arg set value {uuid:"",value:60.0}
execute if score @s zx.bb_ol matches 1 run data modify storage manacore:in arg.value set value 130.0
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function fallendream:lib/mana/pay
execute if data storage manacore:out r{success:0b} run tellraw @s [{"text":"魔力不足 —— 这一箭召不出碎刀","color":"red"}]
execute if data storage manacore:out r{success:0b} run return fail

# ⑥ 伤害 = 基础攻击力 ×0.3 / ×0.5(存 ×1000 的整数, 召唤时算一次)
#   ★ 基础攻击力一律走 manacore stats/get 的 base_attack(不含手持 —— MEMORY 环境段)。
#     `data get ... 1000` 会把 double 乘 1000 再取整, 足够这一档的精度。
function fallendream:equipment/bow/bone_breaker/recalc

# ⑦ 三把刀, 起始角各差 120°(24 档制 ⇒ 0 / 8 / 16)
data modify storage zx:work bbk.a set value 0
execute at @s anchored eyes positioned ^ ^ ^3.5 run function fallendream:equipment/bow/bone_breaker/blade_new with storage zx:work bbk
data modify storage zx:work bbk.a set value 8
execute at @s anchored eyes positioned ^ ^ ^3.5 run function fallendream:equipment/bow/bone_breaker/blade_new with storage zx:work bbk
data modify storage zx:work bbk.a set value 16
execute at @s anchored eyes positioned ^ ^ ^3.5 run function fallendream:equipment/bow/bone_breaker/blade_new with storage zx:work bbk

# ⑧ 表现
execute at @s run playsound minecraft:item.crossbow.shoot player @a ~ ~ ~ 0.6 1.1
execute at @s anchored eyes positioned ^ ^ ^3.5 run particle minecraft:sweep_attack ~ ~ ~ 0.9 0.9 0.9 0.0 6 normal

# ⑨ 「启示录」记页(与其余弩同款; 本件固定消耗 < 100, 不会产生页, 但接口要留着)
function fallendream:equipment/staff/apocalypse/spend
