execute if score @s sdk.state matches 2.. run return run function fallendream:boss/knight/action_tick
execute if score @s sdk.phase matches 1 if score @s sdk.hp matches ..400 if score @s sdk.fall matches 0 run return run function fallendream:boss/knight/start/phase
execute if score @s sdk.fall matches 1.. run return run function fallendream:boss/knight/idle
function fallendream:boss/knight/decide
