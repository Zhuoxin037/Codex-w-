# ============================================================
# sweetdream:equipment/sword/aftersound/second_form —— 余响：5 秒后的第二次召唤
# ------------------------------------------------------------
# 【文案】"若 5 秒后自身术阵未满，则再次召唤一个术阵。之后 12 秒内……"
# 【★ 窗口照开 ★】第二个术阵召不出来（已满）也要进 12 秒窗口 —— 文案的
#   "之后 12 秒"接的是"再召唤一次"这个动作，不是"成功召唤"这个条件。
# ============================================================

function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0

data modify storage manacore:in arg set value {uuid:""}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/formation/count
scoreboard players set #as_u zx.meta 0
scoreboard players set #as_c zx.meta 0
execute store result score #as_u zx.meta run data get storage manacore:out r.count
execute store result score #as_c zx.meta run data get storage manacore:out r.limit
execute if score #as_u zx.meta < #as_c zx.meta run function sweetdream:equipment/sword/aftersound/form5

scoreboard players set @s zx.as_win 1
scoreboard players operation @s zx.as_end = #now manacore.meta
scoreboard players add @s zx.as_end 240
execute at @s run particle minecraft:end_rod ~ ~1 ~ 0.8 0.6 0.8 0.05 16 normal
execute at @s run playsound minecraft:block.amethyst_block.chime player @a ~ ~ ~ 1.0 1.6
