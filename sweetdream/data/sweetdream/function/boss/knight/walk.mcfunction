# Ordinary pursuit only: base +30%, then +10% each 20 successful walk ticks, capped at 1.4x.
execute unless score @s sdk.state matches 1 run scoreboard players set @s sdk.speed 0
execute unless score @s sdk.speed matches 0..80 run scoreboard players set @s sdk.speed 0
execute unless score @s sdk.state matches 1 as @e[tag=sd.kn.current_rig,distance=0..,limit=1] run function sweetdream_boss:dream_knight/animations/walk/play_exclusive
scoreboard players set @s sdk.state 1
execute if score @s sdk.speed matches ..19 run function sweetdream:boss/knight/walk_move {step:0.2535,detour:0.195}
execute if score @s sdk.speed matches 20..39 run function sweetdream:boss/knight/walk_move {step:0.27885,detour:0.2145}
execute if score @s sdk.speed matches 40..59 run function sweetdream:boss/knight/walk_move {step:0.3042,detour:0.234}
execute if score @s sdk.speed matches 60..79 run function sweetdream:boss/knight/walk_move {step:0.32955,detour:0.2535}
execute if score @s sdk.speed matches 80 run function sweetdream:boss/knight/walk_move {step:0.3549,detour:0.273}
execute if score @s sdk.moved matches 1 if score @s sdk.speed matches ..79 run scoreboard players add @s sdk.speed 1
execute if score @s sdk.moved matches 0 run scoreboard players set @s sdk.speed 0
