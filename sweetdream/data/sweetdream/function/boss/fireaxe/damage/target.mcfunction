scoreboard players set @s sdbf.dmgok 0
execute store result score @s sdbf.maxhp run attribute @s minecraft:max_health get 1000
execute store success score @s sdbf.dmgok run function sweetdream:boss/fireaxe/damage/apply with storage sweetdream:fireaxe hit
execute if entity @s[type=minecraft:player] if score @s sdbf.dmgok matches 1 if score @s sdbf.maxhp > @e[tag=sd.fb.current_body,limit=1,distance=0..] sdbf.nexthp run scoreboard players operation @e[tag=sd.fb.current_body,limit=1,distance=0..] sdbf.nexthp = @s sdbf.maxhp
