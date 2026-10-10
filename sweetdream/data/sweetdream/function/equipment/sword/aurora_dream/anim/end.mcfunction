scoreboard players set @s zx.ad_idle 0
scoreboard players set @s zx.ad_wait 0
scoreboard players set @s zx.ad_pulse 0
scoreboard players set #adphase zx.meta 0
execute if items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["aurora_dream"]}] run item modify entity @s weapon.mainhand sweetdream:aurora/idle
execute if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["aurora_dream"]}] run item modify entity @s weapon.offhand sweetdream:aurora/idle
tag @s remove zx.ad_cast
scoreboard players reset @s zx.ad_cast
