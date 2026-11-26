execute unless score @s bs.id = @s bs.id run return 0
execute if score @s bs.wait matches 1.. run return run scoreboard players remove @s bs.wait 1
execute store result storage fallendream:b_staff args.id int 1 run scoreboard players get @s bs.id
function fallendream:boss/b_staff/orphan_check with storage fallendream:b_staff args
