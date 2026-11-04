$execute store success score #s2_moved zx.meta run tp @s $(x) $(y) $(z) ~ 0
execute if score #s2_moved zx.meta matches 1 at @s run function sweetdream:equipment/armor/empty_cicada/moved
