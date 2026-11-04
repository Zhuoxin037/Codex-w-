scoreboard players add @s zx.hurt_total 0
execute if score @s zx.cr_total = @s zx.hurt_total run return 0
scoreboard players add @s zx.cr_seen 0
scoreboard players operation @s zx.cr_loss = @s zx.hurt_total
scoreboard players operation @s zx.cr_loss -= @s zx.cr_seen
scoreboard players operation @s zx.cr_seen = @s zx.hurt_total
scoreboard players operation @s zx.cr_total = @s zx.hurt_total
scoreboard players set #cr_hundred zx.meta 100
scoreboard players operation @s zx.cr_loss *= #cr_hundred zx.meta
execute store result score #cr_current zx.meta run data get entity @s Health 1000
scoreboard players operation #cr_diff zx.meta = @s zx.cr_hp
scoreboard players operation #cr_diff zx.meta -= #cr_current zx.meta
scoreboard players operation #cr_error zx.meta = #cr_diff zx.meta
scoreboard players operation #cr_error zx.meta -= @s zx.cr_loss
execute if score @s zx.cr_hp matches 1.. if score #cr_error zx.meta matches -50..50 if score #cr_diff zx.meta matches 0.. run scoreboard players operation @s zx.cr_loss = #cr_diff zx.meta
scoreboard players operation @s zx.cr_hp = #cr_current zx.meta
