data modify storage fallendream:aggro out set value {success:false}
execute store result storage fallendream:b_staff args.id int 1 run scoreboard players get @s bs.id
function fallendream:boss/b_staff/target/get_one with storage fallendream:b_staff args
