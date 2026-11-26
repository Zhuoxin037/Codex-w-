execute store result storage fallendream:b_staff args.id int 1 run scoreboard players get @s bs.id
function fallendream:boss/b_staff/cleanup_cast with storage fallendream:b_staff args
scoreboard players set @s bs.state 0
scoreboard players set @s bs.age 0
scoreboard players set @s bs.rest 20
scoreboard players set @s bs.oldclip -1
scoreboard players set @s bs.oldframe -1
execute store result score @s bs.lastHP run data get entity @s Health 1000
