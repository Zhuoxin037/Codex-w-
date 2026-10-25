# ============================================================
# sweetdream:equipment/axe/meteor/fall —— 降下陨石(被动命中时)
# ------------------------------------------------------------
# 【执行者】动手的玩家
# 【目标】① 自身攻击的那只(zx.victim)  ② 自身 N 格内随机 M 只
#   并成一个集合 zx.mt_hit 一起处理 —— 万一有重复也不会打两遍(标签天然去重)。
# 【数值】基础攻击力 ×M(通道 attack_mul), 之后缓慢Ⅱ
# 【超限分档(2026-10-23 批 K6)】范围 2→4 格 / 随机 1→3 只 / ×4→×5 / 缓慢 2→3 秒
#   ★ 判 zx.mt_keep=1(超限版)。形态期间换手也一样走超限数值。
# 【④' 陨石实体】每只目标各降一颗 item_display 陨石, 从 7 格高 0.2 秒砸到地面炸开
#   (见 meteor/rock 与 rock_tick 的说明)。它只是表现, 伤害留在 ②。
# ============================================================

scoreboard players add @s zx.mt_keep 0

# ① 圈目标: 刚打中的那只 + 周围随机几只
tag @e[tag=zx.mt_hit] remove zx.mt_hit
tag @e[tag=zx.victim,limit=1] add zx.mt_hit
execute if score @s zx.mt_keep matches 0 at @s run tag @e[type=!#sweetdream:no_damage,distance=0.1..2,sort=random,limit=1] add zx.mt_hit
execute if score @s zx.mt_keep matches 1 at @s run tag @e[type=!#sweetdream:no_damage,distance=0.1..4,sort=random,limit=3] add zx.mt_hit
execute unless entity @e[tag=zx.mt_hit] run return 0

# ② 伤害: 基础攻击力 ×4 / 超限 ×5
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0
data modify storage manacore:in arg set value {uuid:"",attack_mul:4.0}
execute if score @s zx.mt_keep matches 1 run data modify storage manacore:in arg.attack_mul set value 5.0
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/damage/calc
data modify storage zx:in arg set value {target:"@e[tag=zx.mt_hit]",read:"manacore"}
execute at @s run function sweetdream:api/damage

# ③ 缓慢Ⅱ: 2 秒 / 超限 3 秒
execute if score @s zx.mt_keep matches 0 if entity @e[tag=zx.mt_hit] run effect give @e[tag=zx.mt_hit] minecraft:slowness 2 1 true
execute if score @s zx.mt_keep matches 1 if entity @e[tag=zx.mt_hit] run effect give @e[tag=zx.mt_hit] minecraft:slowness 3 1 true

# ④ 表现: 一道火柱从高处砸下来 + 落地炸开
execute at @e[tag=zx.mt_hit] run particle minecraft:flame ~ ~7 ~ 0.2 0.2 0.2 0.08 12 normal
execute at @e[tag=zx.mt_hit] run particle minecraft:lava ~ ~5 ~ 0.2 0.2 0.2 0.0 8 normal
execute at @e[tag=zx.mt_hit] run particle minecraft:explosion ~ ~1 ~ 0.3 0.3 0.3 0.0 1 normal
execute at @e[tag=zx.mt_hit] run particle minecraft:large_smoke ~ ~1 ~ 0.5 0.4 0.5 0.03 12 normal
execute at @e[tag=zx.mt_hit] run playsound minecraft:entity.generic.explode player @a ~ ~ ~ 0.8 0.9

# ④' 落下来的那颗陨石实体(2026-10-08 批 D) —— 从 7 格高处砸下来, 0.2 秒落地炸开。
#   ★ 必须排在 ⑤ 摘 zx.mt_hit 之前: 它按 zx.mt_hit 定位(每只各一颗)。
execute at @e[tag=zx.mt_hit] run function sweetdream:equipment/axe/meteor/rock

tag @e[tag=zx.mt_hit] remove zx.mt_hit
