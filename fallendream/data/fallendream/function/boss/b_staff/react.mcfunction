execute on attacker at @s run function fallendream:boss/b_staff/target/accept
execute store result storage fallendream:b_staff args.id int 1 run scoreboard players get @s bs.id
function fallendream:boss/b_staff/cleanup_cast with storage fallendream:b_staff args
scoreboard players set @s bs.state 3
scoreboard players set @s bs.age 0
scoreboard players set @s bs.reacted 1
scoreboard players set @s bs.rest 20
