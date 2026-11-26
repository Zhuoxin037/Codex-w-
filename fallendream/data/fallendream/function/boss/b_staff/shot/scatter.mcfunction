function fallendream:boss/b_staff/shot/setup
scoreboard players operation #damage bs.dmg = #scatter_cross bs.cfg
scoreboard players set #limit bs.limit 2
scoreboard players set #interval bs.interval 10
data modify storage fallendream:b_staff point set value {x:0d,y:0d,z:0d,owner:0}
execute store result storage fallendream:b_staff args.id int 1 run scoreboard players get @s bs.id
function fallendream:boss/b_staff/shot/read_point with storage fallendream:b_staff args
function fallendream:boss/b_staff/shot/scatter_locked with storage fallendream:b_staff point
