# ============================================================
# fallendream:equipment/armor/air_step/field_hit —— 超限·踏空: 领域里这一跳的结算
# ------------------------------------------------------------
# 【谁调用它】air_step/field_tick ②（`as <施放者>` 切过来，**执行位置仍是领域中心**）
# 【执行者】施放者玩家（@s）
# 【★ 千万不要写 `execute at @s` ★】那会把位置挪到玩家脚下, 半径就变成"围绕玩家"了。
#   本函数全程沿用调用方留下的位置(= 领域 marker 的坐标), 所以 `distance=..4` 是
#   "离领域中心 4 格内"。
# 【文案(lore 逐字)】…每秒都会受到一次相当于释放者基础攻击力的伤害并被击飞 1 格并获得
#   2 秒缓慢Ⅰ。每有一个生物受到影响则自身恢复 10 魔力值。
# ============================================================

function fallendream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0

# ① 伤害：基础攻击力 ×1（走前置包算一次，再交给本包的伤害出口）
data modify storage manacore:in arg set value {uuid:"",attack_mul:1.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/damage/calc
data modify storage zx:in arg set value {target:"@e[type=!#fallendream:no_damage,distance=0.1..4]",damage:0.0}
data modify storage zx:in arg.damage set from storage manacore:out r.damage
function fallendream:internal/attack/api_extra

# ② 击飞 1 格 + 2 秒缓慢Ⅰ（amplifier 0 = Ⅰ）
execute as @e[type=!#fallendream:no_damage,distance=0.1..4] run data modify entity @s Motion set value [0.0d,0.36d,0.0d]
execute as @e[type=!#fallendream:no_damage,distance=0.1..4] run effect give @s minecraft:slowness 2 0 true

# ③ 数受影响的只数（每只 +1），每只回 10 魔力
scoreboard players set #as_n zx.meta 0
execute as @e[type=!#fallendream:no_damage,distance=0.1..4] run scoreboard players add #as_n zx.meta 1
execute if score #as_n zx.meta matches ..0 run return 0
scoreboard players set #as_10 zx.meta 10
scoreboard players operation #as_n zx.meta *= #as_10 zx.meta

data modify storage manacore:in arg set value {uuid:"",value:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute store result storage manacore:in arg.value double 1 run scoreboard players get #as_n zx.meta
function manacore:api/mana/add
