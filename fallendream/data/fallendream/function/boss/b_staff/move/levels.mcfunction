scoreboard players set #safe bs.ok 0
function fallendream:boss/b_staff/move/check
execute if score #safe bs.ok matches 1 run return run function fallendream:boss/b_staff/move/apply
execute positioned ~ ~1 ~ run function fallendream:boss/b_staff/move/check
execute if score #safe bs.ok matches 1 positioned ~ ~1 ~ run return run function fallendream:boss/b_staff/move/apply
execute positioned ~ ~-1 ~ run function fallendream:boss/b_staff/move/check
execute if score #safe bs.ok matches 1 positioned ~ ~-1 ~ run function fallendream:boss/b_staff/move/apply
