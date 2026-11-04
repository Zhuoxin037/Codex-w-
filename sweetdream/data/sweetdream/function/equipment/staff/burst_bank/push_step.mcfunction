execute store success score #s2_moved zx.meta run execute at @s facing entity @a[tag=zx.bb_own,limit=1] feet rotated ~ 0 positioned ^ ^ ^-0.5 if block ~ ~ ~ #minecraft:replaceable if block ~ ~1 ~ #minecraft:replaceable run tp @s ~ ~ ~
execute if score #s2_moved zx.meta matches 1 at @s run function sweetdream:equipment/armor/empty_cicada/moved
