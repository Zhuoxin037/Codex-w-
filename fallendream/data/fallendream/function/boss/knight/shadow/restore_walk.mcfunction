scoreboard players set @s sdk.resamp -1
$execute store result score @s sdk.resamp run data get entity @s $(path).amplifier
$execute if score @s sdk.resamp matches 3 run return run data modify entity @s $(path).duration set value 1
$execute unless data entity @s $(path).hidden_effect run return 0
$data modify storage fallendream:knight restore.path set value "$(path).hidden_effect"
function fallendream:boss/knight/shadow/restore_walk with storage fallendream:knight restore
