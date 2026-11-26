data modify storage fallendream:b_staff hit set value {owner:0,cast:0,amount:0,limit:0,interval:0,now:0,uuid:""}
execute store result storage fallendream:b_staff hit.owner int 1 run scoreboard players get @s bs.owner
execute store result storage fallendream:b_staff hit.cast int 1 run scoreboard players get @s bs.cast
execute store result storage fallendream:b_staff hit.amount int 1 run scoreboard players get @s bs.dmg
execute store result storage fallendream:b_staff hit.limit int 1 run scoreboard players get @s bs.limit
execute store result storage fallendream:b_staff hit.interval int 1 run scoreboard players get @s bs.interval
execute store result storage fallendream:b_staff hit.now int 1 run scoreboard players get #clock bs.clock
