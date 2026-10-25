# A stale/paused animation cannot hold combat indefinitely; do not shorten the 60-tick phase.
execute if score @s sdk.age matches 100.. run return run function sweetdream:boss/knight/recover_action
execute if score @s sdk.state matches 2 run return run function sweetdream:boss/knight/action/double
execute if score @s sdk.state matches 3 run return run function sweetdream:boss/knight/action/left
execute if score @s sdk.state matches 4 run return run function sweetdream:boss/knight/action/right
execute if score @s sdk.state matches 5 run return run function sweetdream:boss/knight/action/wave
execute if score @s sdk.state matches 6 run return run function sweetdream:boss/knight/action/wait
execute if score @s sdk.state matches 7 run return run function sweetdream:boss/knight/action/windup
execute if score @s sdk.state matches 8 run return run function sweetdream:boss/knight/action/run
execute if score @s sdk.state matches 9 run return run function sweetdream:boss/knight/action/thrust
execute if score @s sdk.state matches 10 run return run function sweetdream:boss/knight/action/phase
execute if score @s sdk.state matches 11 run return run function sweetdream:boss/knight/action/combo
execute if score @s sdk.state matches 12 run return run function sweetdream:boss/knight/action/stop

execute if score @s sdk.state matches 13 run return run function sweetdream:boss/knight/action/shadow
