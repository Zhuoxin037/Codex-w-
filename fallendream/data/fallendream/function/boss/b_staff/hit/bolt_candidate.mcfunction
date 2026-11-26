execute if score #touched bs.ok matches 1 run return 0
function fallendream:boss/b_staff/hit/valid
execute if score #valid bs.ok matches 0 run return 0
scoreboard players set #touched bs.ok 1
function fallendream:boss/b_staff/hit/apply
