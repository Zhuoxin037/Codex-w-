# ============================================================
# fallendream:equipment/armor/cross_dream/ol_stop —— 超限·渡梦: 后撤终点的时停与回魔
# ------------------------------------------------------------
# 【谁调用它】cross_dream/on_hurt ⑧（条件已判: 穿着超限渡梦; 已 tp 到后撤终点之后）
# 【执行者】玩家（@s），执行位置就是**后撤终点**
# 【文案(lore 逐字)】…后撤终点3格内若附有「白昼梦」的生物则使其时停1秒，每影响一个
#   生物，则自身恢复12魔力。
# 【★ 先圈人再时停 ★】时停会把 NoAI 打开, 但那不影响 tag; 这里先打临时标 zx.cd_t,
#   交给 lib/timestop 一次处理（它是 `as $(target)`, 多目标逐个跑, 取最长时长）。
# 【★ 计数 ★】`as @e[tag=zx.cd_t] run scoreboard players add #cd_n` —— 每只 +1,
#   比"store result if entity"那种 0/1 判法能真拿到只数。
# ============================================================

# ① 圈人（3 格内、带白昼梦；不排除谁 —— 原文就是"生物"）
tag @e[tag=zx.cd_t] remove zx.cd_t
execute at @s run tag @e[type=!#fallendream:no_damage,distance=..3,tag=zx.status.dream] add zx.cd_t
execute unless entity @e[tag=zx.cd_t] run return 0

# ② 时停 1 秒 = 20 刻
data modify storage zx:work fz set value {target:"@e[tag=zx.cd_t]",ticks:20}
function fallendream:lib/timestop with storage zx:work fz

# ③ 数只数 -> 每只回 12 魔力
scoreboard players set #cd_n zx.meta 0
execute as @e[tag=zx.cd_t] run scoreboard players add #cd_n zx.meta 1
tag @e[tag=zx.cd_t] remove zx.cd_t

scoreboard players set #cd_12 zx.meta 12
scoreboard players operation #cd_n zx.meta *= #cd_12 zx.meta
function fallendream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0
data modify storage manacore:in arg set value {uuid:"",value:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute store result storage manacore:in arg.value double 1 run scoreboard players get #cd_n zx.meta
function manacore:api/mana/add

tellraw @s [{"text":"渡梦","color":"aqua"},{"text":"  后撤终点的梦境被定住了（每只回 12 魔力）","color":"gray"}]
execute at @s run particle minecraft:end_rod ~ ~1 ~ 0.6 0.5 0.6 0.03 14 normal
