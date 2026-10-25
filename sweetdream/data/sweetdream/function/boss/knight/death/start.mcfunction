execute if entity @s[tag=sd.kn.dead] run return 0
tag @s add sd.kn.dead
tag @s remove sd.kn.frozen
scoreboard players set @s sdk.death 0
execute store result storage sweetdream:knight args.id int 1 run scoreboard players get @s aj.id
data modify storage sweetdream:knight shadow_owner.owner set from storage sweetdream:knight args.id
function sweetdream:boss/knight/shadow/release_owner with storage sweetdream:knight shadow_owner
function sweetdream:boss/knight/cleanup_fx with storage sweetdream:knight args
function sweetdream:boss/knight/bar_remove with storage sweetdream:knight args
function sweetdream_boss:dream_knight/animations/kneel/play_exclusive
