execute store result score @s sdk.choice run random value 0..3
execute if score @s sdk.phase matches 2 store result score @s sdk.choice run random value 0..2
execute if score @s sdk.circlecd matches 0 unless score @s sdk.lastmove matches 1 if score @s sdk.choice matches 0 run return run function fallendream:boss/knight/circle_choose
function fallendream:boss/knight/start/double
