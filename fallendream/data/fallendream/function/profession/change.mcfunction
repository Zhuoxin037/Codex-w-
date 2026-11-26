scoreboard players remove #jselect zx.meta 1
execute if score @s zx.job = #jselect zx.meta run return 0
function fallendream:profession/cleanup
scoreboard players operation @s zx.job = #jselect zx.meta
scoreboard players set @s zx.j_aw 0
execute if score @s zx.job matches 1 run scoreboard players operation @s zx.j_aw = @s zx.j_aw_m
execute if score @s zx.job matches 2 run scoreboard players operation @s zx.j_aw = @s zx.j_aw_b
execute if score @s zx.job matches 3 run scoreboard players operation @s zx.j_aw = @s zx.j_aw_s
execute if score @s zx.job matches 4 run scoreboard players operation @s zx.j_aw = @s zx.j_aw_t
function fallendream:profession/stats
execute if score @s zx.job matches 1 run function fallendream:profession/mage/starter
execute if score @s zx.job matches 4 run function fallendream:profession/twin/starter
tellraw @s {"text":"职业已切换。职业资源与持续效果已清理。","color":"green"}

function fallendream:profession/weapon_guard

function fallendream:equipment/tool/dream_waker/sync
