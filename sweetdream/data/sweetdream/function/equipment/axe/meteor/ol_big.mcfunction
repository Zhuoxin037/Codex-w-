# ============================================================
# sweetdream:equipment/axe/meteor/ol_big —— 超限·熔星形态: 30% 再降一颗「大陨石」
# ------------------------------------------------------------
# 【谁调用它】meteor/hit_go 末段(只在 mt_keep=1 且 mt_on≥1 = 超限版熔星形态期间)
# 【执行者】动手的玩家
# 【文案】"每次攻击都有 30% 的概率对自身 4 格内的随机一个生物及自身攻击的生物
#         降下一个大陨石, 且对其造成相当于自身基础攻击力 ×8 的伤害,
#         之后使其获得 3 秒缓慢Ⅴ效果。"
# 【和普通被动的关系】两者**独立**: 熔星形态下被动已经是 100%(×5/缓慢Ⅱ),
#   本条是在它之外再掷一次 30%(×8/缓慢Ⅴ)。所以一次平A可能同时落两拨石头。
# 【★ 必须排在"清 zx.victim"之前 ★】它要打"自身攻击的那只"。
# 【目标集合】victim + 4 格内随机 1 只, 合成 zx.mt_big 一起结算(标签天然去重)。
# ============================================================

# ① 30%: #rnd %10 落在 0..2
function sweetdream:lib/rnd
scoreboard players operation #mto_r zx.meta = #rnd zx.meta
scoreboard players operation #mto_r zx.meta %= #10 zx.meta
execute if score #mto_r zx.meta >= #3 zx.meta run return 0

# ② 圈目标
tag @e[tag=zx.mt_big] remove zx.mt_big
tag @e[tag=zx.victim,limit=1] add zx.mt_big
execute at @s run tag @e[type=!#sweetdream:no_damage,distance=0.1..4,sort=random,limit=1] add zx.mt_big
execute unless entity @e[tag=zx.mt_big] run return 0

# ③ 伤害: 基础攻击力 ×8
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0
data modify storage manacore:in arg set value {uuid:"",attack_mul:8.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/damage/calc
data modify storage zx:in arg set value {target:"@e[tag=zx.mt_big]",read:"manacore"}
execute at @s run function sweetdream:api/damage

# ④ 3 秒缓慢Ⅴ(amplifier 4)
execute if entity @e[tag=zx.mt_big] run effect give @e[tag=zx.mt_big] minecraft:slowness 3 4 true

# ⑤ 表现: 更粗的火柱 + 更响的炸裂
execute at @e[tag=zx.mt_big] run particle minecraft:flame ~ ~7 ~ 0.4 0.4 0.4 0.1 24 normal
execute at @e[tag=zx.mt_big] run particle minecraft:lava ~ ~5 ~ 0.4 0.4 0.4 0.0 16 normal
execute at @e[tag=zx.mt_big] run particle minecraft:explosion ~ ~1 ~ 0.6 0.6 0.6 0.0 2 normal
execute at @e[tag=zx.mt_big] run playsound minecraft:entity.generic.explode player @a ~ ~ ~ 1.0 0.7

# ⑥ 落下一颗放大的陨石实体
execute at @e[tag=zx.mt_big] run function sweetdream:equipment/axe/meteor/ol_rock

tag @e[tag=zx.mt_big] remove zx.mt_big
