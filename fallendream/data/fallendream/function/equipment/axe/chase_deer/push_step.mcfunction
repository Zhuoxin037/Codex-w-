execute unless block ^ ^ ^-.25 #minecraft:replaceable run return 0
execute unless block ^ ^1 ^-.25 #minecraft:replaceable run return 0
tp @s ^ ^ ^-.25
scoreboard players add @s zx.s2_i 1
execute if score @s zx.s2_i matches ..5 positioned ^ ^ ^-.25 run function fallendream:equipment/axe/chase_deer/push_step
