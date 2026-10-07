# ============================================================
# sweetdream:equipment/axe/meteor/fall —— 降下陨石(被动命中时)
# ------------------------------------------------------------
# 【执行者】动手的玩家
# 【目标】① 自身攻击的那只(zx.victim)  ② 自身 2 格内随机的一只
#   两只并成一个集合 zx.mt_hit 一起处理 —— 万一它俩是同一只也不会打两遍。
# 【数值】基础攻击力 ×4(通道 attack_mul), 之后 2 秒缓慢Ⅱ(amplifier 1)。
# ============================================================

# ① 圈目标: 刚打中的那只 + 2 格内随机一只
tag @e[tag=zx.mt_hit] remove zx.mt_hit
tag @e[tag=zx.victim,limit=1] add zx.mt_hit
execute at @s run tag @e[type=!#sweetdream:no_damage,distance=0.1..2,sort=random,limit=1] add zx.mt_hit
execute unless entity @e[tag=zx.mt_hit] run return 0

# ② 伤害: 基础攻击力 ×4
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0
data modify storage manacore:in arg set value {uuid:"",attack_mul:4.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/damage/calc
data modify storage zx:in arg set value {target:"@e[tag=zx.mt_hit]",read:"manacore"}
execute at @s run function sweetdream:api/damage

# ③ 2 秒缓慢Ⅱ
execute if entity @e[tag=zx.mt_hit] run effect give @e[tag=zx.mt_hit] minecraft:slowness 2 1 true

# ④ 表现: 一道火柱从高处砸下来 + 落地炸开
execute at @e[tag=zx.mt_hit] run particle minecraft:flame ~ ~7 ~ 0.2 0.2 0.2 0.08 12 normal
execute at @e[tag=zx.mt_hit] run particle minecraft:lava ~ ~5 ~ 0.2 0.2 0.2 0.0 8 normal
execute at @e[tag=zx.mt_hit] run particle minecraft:explosion ~ ~1 ~ 0.3 0.3 0.3 0.0 1 normal
execute at @e[tag=zx.mt_hit] run particle minecraft:large_smoke ~ ~1 ~ 0.5 0.4 0.5 0.03 12 normal
execute at @e[tag=zx.mt_hit] run playsound minecraft:entity.generic.explode player @a ~ ~ ~ 0.8 0.9

tag @e[tag=zx.mt_hit] remove zx.mt_hit
