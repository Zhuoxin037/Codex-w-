execute unless score @s zx.ad_idle matches 0..23 run scoreboard players set @s zx.ad_idle 0
execute unless score @s zx.ad_wait matches 0..3 run scoreboard players set @s zx.ad_wait 0
execute if score @s zx.ad_wait matches 0 run function sweetdream:equipment/sword/aurora_dream/anim/idle_step
scoreboard players add @s zx.ad_wait 1
execute if score @s zx.ad_wait matches 4.. run scoreboard players set @s zx.ad_wait 0
