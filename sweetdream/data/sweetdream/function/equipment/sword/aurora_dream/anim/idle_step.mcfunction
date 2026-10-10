scoreboard players operation #adphase zx.meta = @s zx.ad_idle
execute if items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["aurora_dream"]}] run item modify entity @s weapon.mainhand sweetdream:aurora/idle
execute if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["aurora_dream"]}] run item modify entity @s weapon.offhand sweetdream:aurora/idle
scoreboard players add @s zx.ad_idle 1
execute if score @s zx.ad_idle matches 24.. run scoreboard players set @s zx.ad_idle 0
