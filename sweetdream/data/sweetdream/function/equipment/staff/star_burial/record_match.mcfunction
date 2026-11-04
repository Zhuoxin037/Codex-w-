$execute unless data entity $(target) {last_hurt_by_player:[I;$(a0),$(a1),$(a2),$(a3)]} run return 0
scoreboard players operation #burial_loss zx.meta = @s zx.burial_hp
$execute store result score #burial_cur zx.meta run data get entity $(target) Health 1000
scoreboard players operation #burial_loss zx.meta -= #burial_cur zx.meta
scoreboard players operation #burial_abs zx.meta = @s zx.burial_abs
scoreboard players set #burial_nowabs zx.meta 0
$execute if data entity $(target) AbsorptionAmount store result score #burial_nowabs zx.meta run data get entity $(target) AbsorptionAmount 1000
scoreboard players operation #burial_abs zx.meta -= #burial_nowabs zx.meta
execute if score #burial_abs zx.meta matches 1.. run scoreboard players operation #burial_loss zx.meta += #burial_abs zx.meta
scoreboard players operation @s zx.burial_hp = #burial_cur zx.meta
scoreboard players operation @s zx.burial_abs = #burial_nowabs zx.meta
execute unless score #burial_loss zx.meta matches 1.. run return 0
$execute if data entity @s {data:{u0:$(a0),u1:$(a1),u2:$(a2),u3:$(a3)}} run function sweetdream:equipment/staff/star_burial/record_add
