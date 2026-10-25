function sweetdream:boss/knight/shadow/release
scoreboard players set @s sdk.state 0
scoreboard players set @s sdk.rest 60
execute store result storage sweetdream:knight shadow_owner.owner int 1 run scoreboard players get @s sdk.id
function sweetdream:boss/knight/shadow/reload_idle with storage sweetdream:knight shadow_owner
