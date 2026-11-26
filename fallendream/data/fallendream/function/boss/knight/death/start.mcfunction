execute if entity @s[tag=sd.kn.dead] run return 0
function fallendream:boss/knight/blink/show
tag @s add sd.kn.dead
tag @s remove sd.kn.frozen
scoreboard players set @s sdk.death 0
execute store result storage fallendream:knight args.id int 1 run scoreboard players get @s aj.id
data modify storage fallendream:knight shadow_owner.owner set from storage fallendream:knight args.id
function fallendream:boss/knight/shadow/release_owner with storage fallendream:knight shadow_owner
function fallendream:boss/knight/cleanup_fx with storage fallendream:knight args
function fallendream:boss/knight/bar_remove with storage fallendream:knight args
function fallendream_boss:dream_knight/animations/kneel/play_exclusive
