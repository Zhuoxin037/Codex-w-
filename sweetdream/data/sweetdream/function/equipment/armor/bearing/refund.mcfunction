# ============================================================
# sweetdream:equipment/armor/bearing/refund —— 术阵减少时返还 25 魔力/个（每秒）
# ------------------------------------------------------------
# 【执行者】玩家（已确认穿着「承」且套装成立）
# 【文案】"术阵自然结束或被主动归还时，返还 25 点魔力值。"
# 【★ 判据 = 占用数下降 ★】zx.br_fm 记上一秒的 zx.fm_u（注意 lib/fm/read 已经在本函数
#   之前跑完，所以 @s zx.fm_u 是**本秒**的值）。
# 【★ 上限夹取交给 manacore ★】mana/add 内部会夹到最大魔力，不需要自己判。
# ============================================================

# 【★ 套装成立才返还 ★】这段文案在 lore 里属于「✦ 套装效果」段 ⇒ 和「阵成」一样
#   要求「枢」在头。没穿枢的时候把基线同步住（否则重新戴枢的那一秒会补发一笔）。
execute unless items entity @s armor.head *[minecraft:custom_data~{zx:["pivot"]}] run scoreboard players operation @s zx.br_fm = @s zx.fm_u
execute unless items entity @s armor.head *[minecraft:custom_data~{zx:["pivot"]}] run return 0

# 第一次跑（没记录）⇒ 只记基线，不返还
execute unless score @s zx.br_fm matches 0.. run scoreboard players operation @s zx.br_fm = @s zx.fm_u
execute unless score @s zx.br_fm matches 0.. run return 0

# 掉了几个（本秒比上秒少）
scoreboard players set #br_drop zx.meta 0
scoreboard players operation #br_drop zx.meta = @s zx.br_fm
scoreboard players operation #br_drop zx.meta -= @s zx.fm_u
execute if score #br_drop zx.meta matches ..0 run scoreboard players operation @s zx.br_fm = @s zx.fm_u
execute if score #br_drop zx.meta matches ..0 run return 0

# 25 × 掉的数量
scoreboard players set #br_25 zx.meta 25
scoreboard players operation #br_drop zx.meta *= #br_25 zx.meta

function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run scoreboard players operation @s zx.br_fm = @s zx.fm_u
execute unless data storage zx:data self{ok:1b} run return 0

data modify storage zx:work mr.value set value 0.0
execute store result storage zx:work mr.value double 1 run scoreboard players get #br_drop zx.meta
data modify storage manacore:in arg set value {uuid:"",value:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
data modify storage manacore:in arg.value set from storage zx:work mr.value
function manacore:api/mana/add

tellraw @s [{"text":"术阵结束，返还魔力值","color":"aqua"}]
scoreboard players operation @s zx.br_fm = @s zx.fm_u
