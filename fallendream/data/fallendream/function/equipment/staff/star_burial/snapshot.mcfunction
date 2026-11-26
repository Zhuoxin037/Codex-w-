$execute store result score @s zx.burial_hp run data get entity $(target) Health 1000
scoreboard players set @s zx.burial_abs 0
$execute if data entity $(target) AbsorptionAmount store result score @s zx.burial_abs run data get entity $(target) AbsorptionAmount 1000
