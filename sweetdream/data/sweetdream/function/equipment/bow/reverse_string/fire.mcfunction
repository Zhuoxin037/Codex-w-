# ============================================================
# sweetdream:equipment/bow/reverse_string/fire —— 「逆弦」结算(宏 {target, shooter, uuid})
# ------------------------------------------------------------
# 【执行者】射手(玩家), 位置/朝向 = 射手自己(apply 用 as/at 送进来)
# 【文案】每次射击命中生物后, 额外造成一次相当于自身基础攻击力 ×2 的伤害。
#   若自身**当前魔力值不高于最大魔力值的 25%**, 则该段技能伤害提高 50%(独立乘区);
#   若强化段击杀了生物, 则返还 40 魔力。
# 【★ "强化"的判据取哪一刻 ★】按**命中结算这一刻**的当前魔力值(文案写"自身当前
#   魔力值", 没有"命中前"的措辞, 而伤害本来就是这一刻打的)。
# 【★ 独立乘区怎么给 ★】calc 的 independent_multiplier 是**整体乘区** ——
#   把 attack_mul 保持 2.0, 只把 im 设成 1.5 即可, 不需要自己去乘系数
#   (同 爆裂黎明 的 im 用法)。
# 【★ 击杀返还怎么数 ★】坑 134/135: 被这一下打死的实体**这一刻已从世界移除**,
#   `@e` 选不到它(MC-108307) ⇒ 不能"逐只读 Health 判死"。
#   本件只有一个目标 ⇒ 用"打完前后各看一次 zx.rs_v 标签还在不在"的差值法:
#   结算前它一定在, 结算后不在 = 死了。
# 【★ 超限(批 K7, 2026-10-23) ★】主手那把带 ol:"reverse_string"(shot 已把
#   zx.rs_ov 写进玩家身上)时, 本函数有三处不同:
#     · 低魔门槛 25% -> 30%(判据仍是整数比较, 见 ①);
#     · 强化段 +50% -> +200%, 即独立乘区 1.5 -> 3.0;
#     · 击杀返还 40 -> 140(= 本次消耗 280 的 50%)。
#   伤害本体(基础攻击力 ×2)、每发都结算的口径都不变。
# ============================================================

# ⓪ 受害者还在吗
execute unless entity @e[tag=zx.rs_v,distance=0..,limit=1] run return 0

# ① 判"强化": 当前魔力 ×4 <= 最大魔力(即 当前 ≤ 25%)
#   ★ 超限(批 K7)门槛 25% -> 30%: 当前 ×10 <= 最大 ×3
#     (同一个判据换个分母, 不用浮点 —— 计分项只有整数)
data modify storage manacore:in arg set value {uuid:"",key:"current_mana"}
data modify storage manacore:in arg.uuid set from storage zx:work rs.uuid
function manacore:api/stats/get
execute store result score #rs_cm zx.meta run data get storage manacore:out r.value
data modify storage manacore:in arg set value {uuid:"",key:"max_mana"}
data modify storage manacore:in arg.uuid set from storage zx:work rs.uuid
function manacore:api/stats/get
execute store result score #rs_mm zx.meta run data get storage manacore:out r.value
scoreboard players set #rs_ol zx.meta 0
#   ★ 两个名字别混: #rs_ol = "这一发进了强化档"(局部假名);
#     zx.rs_ov = "这一发是超限弩射的"(挂在射手身上, shot 写的)。
#   ★ 两套判据**必须互斥**: 先 ×4 再 ×10 会变成"当前 ≤ 7.5%", 门槛反而更严。
execute if score @s zx.rs_ov matches 0 run scoreboard players operation #rs_cm zx.meta *= #4 zx.meta
execute if score @s zx.rs_ov matches 0 if score #rs_cm zx.meta <= #rs_mm zx.meta run scoreboard players set #rs_ol zx.meta 1
execute if score @s zx.rs_ov matches 1 run scoreboard players operation #rs_cm zx.meta *= #10 zx.meta
execute if score @s zx.rs_ov matches 1 run scoreboard players operation #rs_mm zx.meta *= #3 zx.meta
execute if score @s zx.rs_ov matches 1 if score #rs_cm zx.meta <= #rs_mm zx.meta run scoreboard players set #rs_ol zx.meta 1

# ② 伤害 = 基础攻击力 ×2; 强化时整段 ×1.5(独立乘区)
#   ★ 超限(批 K7): "+50%" -> "+200%", 即独立乘区 1.5 -> 3.0(3 倍)
data modify storage manacore:in arg set value {uuid:"",attack_mul:2.0,independent_multiplier:1.0}
execute if score #rs_ol zx.meta matches 1 run data modify storage manacore:in arg.independent_multiplier set value 1.5
execute if score #rs_ol zx.meta matches 1 if score @s zx.rs_ov matches 1 run data modify storage manacore:in arg.independent_multiplier set value 3.0
data modify storage manacore:in arg.uuid set from storage zx:work rs.uuid
function manacore:api/damage/calc
data modify storage zx:work rs.dmg set value 0.0
data modify storage zx:work rs.dmg set from storage manacore:out r.damage
# 诊断锚 #rs_dbg8 = 这一段额外伤害(×1000); #rs_ol 本身就是"是否强化(0/1)"的探针
scoreboard players set #rs_dbg8 zx.meta 0
execute store result score #rs_dbg8 zx.meta run data get storage zx:work rs.dmg 1000
execute store result storage zx:work rs.u0 int 1 run data get entity @s UUID[0]
execute store result storage zx:work rs.u1 int 1 run data get entity @s UUID[1]
execute store result storage zx:work rs.u2 int 1 run data get entity @s UUID[2]
execute store result storage zx:work rs.u3 int 1 run data get entity @s UUID[3]

# ③ 打出这一段伤害(带射手归属)
execute as @e[tag=zx.rs_v,distance=0..,limit=1] at @s run function sweetdream:equipment/bow/reverse_string/strike

# ④ 击杀返还: **只在强化段**; 打完标签还在 = 没死, 标签没了 = 死了(差值法)
#   ★ 超限(批 K7): 返还"本次消耗的 50%" —— 超限每发固定 280 蓝 ⇒ 返还 140。
#     (普通仍是 40。文案两档都是定值, 所以直接写数, 不去反查扣了多少。)
execute if score #rs_ol zx.meta matches 1 unless entity @e[tag=zx.rs_v,distance=0..,limit=1] run data modify storage manacore:in arg set value {uuid:"",value:40.0}
execute if score #rs_ol zx.meta matches 1 unless entity @e[tag=zx.rs_v,distance=0..,limit=1] if score @s zx.rs_ov matches 1 run data modify storage manacore:in arg.value set value 140.0
execute if score #rs_ol zx.meta matches 1 unless entity @e[tag=zx.rs_v,distance=0..,limit=1] run data modify storage manacore:in arg.uuid set from storage zx:work rs.uuid
execute if score #rs_ol zx.meta matches 1 unless entity @e[tag=zx.rs_v,distance=0..,limit=1] run function manacore:api/mana/add
execute if score #rs_ol zx.meta matches 1 unless entity @e[tag=zx.rs_v,distance=0..,limit=1] if score @s zx.rs_ov matches 0 run tellraw @s [{"text":"「逆弦」强化段击杀 —— 返还 40 魔力","color":"aqua"}]
execute if score #rs_ol zx.meta matches 1 unless entity @e[tag=zx.rs_v,distance=0..,limit=1] if score @s zx.rs_ov matches 1 run tellraw @s [{"text":"「超限·逆弦」强化段击杀 —— 返还 140 魔力","color":"aqua"}]

# ⑤ 收尾
tag @e[tag=zx.rs_v,distance=0..] remove zx.rs_v
