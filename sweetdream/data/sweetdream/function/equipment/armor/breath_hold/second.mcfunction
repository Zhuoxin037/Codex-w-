# ============================================================
# sweetdream:equipment/armor/breath_hold/second —— 「屏息」每秒回魔
# ------------------------------------------------------------
# 【执行者】玩家（lib/fm/read 之后）
# 【文案】魔力 +60（armor_mana 登记）。每有 1 个空闲术阵位，每秒恢复 2 点魔力值。
#   术阵位全满时，改为每秒恢复 1 点魔力值。
# 【★ 空闲 = 上限 − 占用 ★】用 zx.fm_c / zx.fm_u。
# 【★ 全满也给 1 点 ★】文案是"改为"，不是"不再恢复"。
# ============================================================

execute unless items entity @s armor.head *[minecraft:custom_data~{zx:["breath_hold"]}] run return 0

scoreboard players operation #bh_free zx.meta = @s zx.fm_c
scoreboard players operation #bh_free zx.meta -= @s zx.fm_u

# 全满（空闲 ≤0）⇒ 1 点
scoreboard players set #bh_re zx.meta 0
execute if score #bh_free zx.meta matches ..0 run scoreboard players set #bh_re zx.meta 1

# 有空闲 ⇒ 空闲 ×2
execute if score #bh_free zx.meta matches 1.. run scoreboard players operation #bh_re zx.meta = #bh_free zx.meta
scoreboard players set #bh_2 zx.meta 2
execute if score #bh_free zx.meta matches 1.. run scoreboard players operation #bh_re zx.meta *= #bh_2 zx.meta

execute if score #bh_re zx.meta matches ..0 run return 0

function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0
data modify storage zx:work mr.value set value 0.0
execute store result storage zx:work mr.value double 1 run scoreboard players get #bh_re zx.meta
data modify storage manacore:in arg set value {uuid:"",value:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
data modify storage manacore:in arg.value set from storage zx:work mr.value
function manacore:api/mana/add
