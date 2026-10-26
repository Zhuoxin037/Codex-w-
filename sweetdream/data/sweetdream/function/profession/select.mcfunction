scoreboard players operation #jselect zx.meta = @s zx.jobpick_tg
scoreboard players set @s zx.jobpick_tg 0
execute if score #jselect zx.meta matches 1..5 run function sweetdream:profession/change
scoreboard players enable @s zx.jobpick_tg
