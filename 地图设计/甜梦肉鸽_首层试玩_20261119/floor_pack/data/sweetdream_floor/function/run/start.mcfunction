execute unless dimension minecraft:overworld run return 0
execute if entity @a[tag=sd.floor_run] run return run tellraw @s {"text":"现有一局进行中。","color":"yellow"}
execute if score #rv_clean zx.meta matches 1.. run return run tellraw @s {"text":"上一局正在退场，请稍候再点。","color":"yellow"}
execute unless entity @s[x=-67,y=90,z=36,dx=28,dy=6,dz=23] run return 0
tag @s add sd.floor_run
scoreboard players add #serial sd.floor 1
scoreboard players operation @s sd.floor = #serial sd.floor
scoreboard players set @s sd.floor_death 0
scoreboard players set #phase sd.floor 1
scoreboard players set #ready sd.floor 0
scoreboard players set #last sd.floor -1
scoreboard players set #fights sd.floor 0
scoreboard players set #room_anchor sd.floor 10
scoreboard players set #lumen sd.floor 0
scoreboard players set #budget sd.floor 8
data modify storage sweetdream_floor:run exploration set value 1b
data remove storage sweetdream_floor:run exploration_doors
scoreboard players set #boon sd.floor 0
data modify storage sweetdream_floor:run rooms set value []
effect clear @s
tag @s remove sd.floor_kit
clear @s
function sweetdream_floor:run/clear_chest
function sweetdream_floor:run/reset_cooldowns
function sweetdream:profession/cleanup
scoreboard players set @s zx.j_f_given 0
scoreboard players set @s zx.j_aw 0
scoreboard players set @s zx.j_aw_m 0
scoreboard players set @s zx.j_aw_b 0
scoreboard players set @s zx.j_aw_s 0
scoreboard players set @s zx.j_aw_t 0
scoreboard players set @s zx.job -1
scoreboard players operation #jselect zx.meta = #input sd.floor
scoreboard players remove #jselect zx.meta 9
function sweetdream:profession/change
function sweetdream_floor:run/starter
function sweetdream_floor:run/refill
title @s times 5 35 12
title @s subtitle {"text":"房间编排中 · 地图正在成形","color":"gray"}
title @s title {"text":"入 梦","color":"aqua"}
playsound minecraft:block.beacon.activate master @s ~ ~ ~ 0.7 0.7
function sweetdream:rogue/prototype/start
