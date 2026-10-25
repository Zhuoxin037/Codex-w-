function sweetdream:boss/knight/shadow/release
execute store result storage sweetdream:knight shadow_owner.owner int 1 run scoreboard players get @s sdk.id
function sweetdream:boss/knight/shadow/cleanup_owner with storage sweetdream:knight shadow_owner
function sweetdream:boss/knight/finish
scoreboard players set @s sdk.rest 60
