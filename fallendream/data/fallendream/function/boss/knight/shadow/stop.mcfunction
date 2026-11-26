function fallendream:boss/knight/shadow/release
execute store result storage fallendream:knight shadow_owner.owner int 1 run scoreboard players get @s sdk.id
function fallendream:boss/knight/shadow/cleanup_owner with storage fallendream:knight shadow_owner
function fallendream:boss/knight/finish
scoreboard players set @s sdk.rest 60
