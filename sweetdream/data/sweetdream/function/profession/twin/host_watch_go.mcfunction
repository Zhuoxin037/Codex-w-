scoreboard players set #jhostfound zx.meta 0
$execute in minecraft:overworld if entity @e[type=!minecraft:player,distance=0..,nbt={UUID:[I;$(t0),$(t1),$(t2),$(t3)]},limit=1] run scoreboard players set #jhostfound zx.meta 1
$execute in minecraft:overworld if entity @e[type=!minecraft:player,distance=0..,nbt={UUID:[I;$(t0),$(t1),$(t2),$(t3)]},limit=1] run tp @s @e[type=!minecraft:player,distance=0..,nbt={UUID:[I;$(t0),$(t1),$(t2),$(t3)]},limit=1]
$execute in minecraft:the_nether if entity @e[type=!minecraft:player,distance=0..,nbt={UUID:[I;$(t0),$(t1),$(t2),$(t3)]},limit=1] run scoreboard players set #jhostfound zx.meta 1
$execute in minecraft:the_nether if entity @e[type=!minecraft:player,distance=0..,nbt={UUID:[I;$(t0),$(t1),$(t2),$(t3)]},limit=1] run tp @s @e[type=!minecraft:player,distance=0..,nbt={UUID:[I;$(t0),$(t1),$(t2),$(t3)]},limit=1]
$execute in minecraft:the_end if entity @e[type=!minecraft:player,distance=0..,nbt={UUID:[I;$(t0),$(t1),$(t2),$(t3)]},limit=1] run scoreboard players set #jhostfound zx.meta 1
$execute in minecraft:the_end if entity @e[type=!minecraft:player,distance=0..,nbt={UUID:[I;$(t0),$(t1),$(t2),$(t3)]},limit=1] run tp @s @e[type=!minecraft:player,distance=0..,nbt={UUID:[I;$(t0),$(t1),$(t2),$(t3)]},limit=1]
execute if score #jhostfound zx.meta matches 0 as @a[tag=zx.ub,limit=1] at @s run function sweetdream:profession/twin/host_died
execute if score #jhostfound zx.meta matches 0 run kill @s
