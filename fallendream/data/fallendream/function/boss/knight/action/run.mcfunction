# Relocate during the hidden interval; reveal one tick later at the new position.
scoreboard players add @s sdk.age 1
execute if score @s sdk.age matches 1 run function fallendream:boss/knight/blink/relocate
execute if score @s sdk.state matches 8 if score @s sdk.age matches 2.. run function fallendream:boss/knight/blink/reveal
