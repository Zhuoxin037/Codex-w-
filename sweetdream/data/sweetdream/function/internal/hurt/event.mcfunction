advancement revoke @s only sweetdream:internal/hurt
scoreboard players add @s zx.hurt_total 0
scoreboard players add @s zx.hurt_seen 0
scoreboard players operation @s zx.hurt_evt = @s zx.hurt_total
scoreboard players operation @s zx.hurt_evt -= @s zx.hurt_seen
scoreboard players operation @s zx.hurt_seen = @s zx.hurt_total
execute if score @s zx.hurt_evt matches ..0 run scoreboard players set @s zx.hurt_evt 0
execute if score @s zx.hurt_evt matches 21474837.. run scoreboard players set @s zx.hurt_evt 21474836
scoreboard players operation @s zx.hurt_evt *= #100 zx.meta

execute if score @s zx.hurt_evt matches 1.. if items entity @s armor.head *[minecraft:custom_data~{zx:["glimmer"]}] at @s run function sweetdream:equipment/armor/glimmer/clear
execute if score @s zx.hurt_evt matches 1.. if score @s zx.ld_r5 matches 1.. run effect clear @s minecraft:resistance
execute if score @s zx.hurt_evt matches 1.. if score @s zx.ld_r5 matches 1.. run scoreboard players set @s zx.ld_r5 0
execute unless items entity @s armor.chest *[minecraft:custom_data~{zx:["huilan"]}] unless items entity @s weapon.offhand *[minecraft:custom_data~{zx:["retro_shine"]}] unless items entity @s weapon.offhand *[minecraft:custom_data~{zx:["sip_frost"]}] unless score @s zx.wb_on matches 1 run return 0
function sweetdream:lib/hurt_gain
execute if score @s zx.hurt_evt matches 1.. run function sweetdream:equipment/armor/huilan/on_hurt
execute if score @s zx.hurt_evt matches 1.. run function sweetdream:equipment/sword/way_back/on_hurt
