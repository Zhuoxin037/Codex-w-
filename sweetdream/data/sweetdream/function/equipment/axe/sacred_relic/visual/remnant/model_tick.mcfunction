# @s = 单一显示实体。逻辑 marker 仍在 240 刻准确到期；显示最多多留 17 刻散去。
execute unless score @s zx.srm_b matches 0.. run return run function sweetdream:equipment/axe/sacred_relic/visual/remnant/cleanup
execute unless score @s zx.srm_end matches 0.. run return run function sweetdream:equipment/axe/sacred_relic/visual/remnant/cleanup
scoreboard players set #srm_vehicle zx.srm_f 0
execute on passengers if entity @s[type=minecraft:marker,tag=zx.sr_relic] run scoreboard players set #srm_vehicle zx.srm_f 1
execute if score @s zx.srm_d matches -1 if score #srm_vehicle zx.srm_f matches 0 run scoreboard players operation @s zx.srm_d = #now manacore.meta
execute if score @s zx.srm_d matches -1 if score @s zx.srm_end <= #now manacore.meta run scoreboard players operation @s zx.srm_d = #now manacore.meta
execute if score @s zx.srm_d matches 0.. run return run function sweetdream:equipment/axe/sacred_relic/visual/remnant/vanish
# 待机 4 秒循环，每四刻换帧；出生相位使多具遗骸不会整齐地一起闪。
scoreboard players operation #srm_age zx.srm_f = #now manacore.meta
scoreboard players operation #srm_age zx.srm_f -= @s zx.srm_b
scoreboard players operation #srm_frame zx.srm_f = #srm_age zx.srm_f
scoreboard players operation #srm_frame zx.srm_f %= #srm_80 zx.srm_f
scoreboard players operation #srm_frame zx.srm_f /= #srm_4 zx.srm_f
# 实际命中后的 1 秒共鸣，五处印记保持原位置和原尺寸。
scoreboard players operation #srm_p_age zx.srm_f = #now manacore.meta
scoreboard players operation #srm_p_age zx.srm_f -= @s zx.srm_p
execute if score @s zx.srm_p matches 0.. if score #srm_p_age zx.srm_f matches 0..19 run scoreboard players operation #srm_frame zx.srm_f = #srm_p_age zx.srm_f
execute if score @s zx.srm_p matches 0.. if score #srm_p_age zx.srm_f matches 0..19 run scoreboard players add #srm_frame zx.srm_f 200
# 生成阶段优先完成原尺寸骨尘显露，避免刚出生就跳到完整骨架。
execute if score #srm_age zx.srm_f matches 0..16 run scoreboard players operation #srm_frame zx.srm_f = #srm_age zx.srm_f
execute if score #srm_age zx.srm_f matches 0..16 run scoreboard players add #srm_frame zx.srm_f 100
function sweetdream:equipment/axe/sacred_relic/visual/remnant/apply
