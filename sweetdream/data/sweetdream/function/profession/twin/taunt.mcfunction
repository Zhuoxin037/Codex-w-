execute if entity @s[tag=zx.j_eroded] run return 0
scoreboard players set #jclosest_body zx.meta 0
execute as @e[tag=zx.j_body,distance=..16,sort=nearest,limit=1] if entity @s[tag=zx.j_taunt_body] run scoreboard players set #jclosest_body zx.meta 1
execute unless score #jclosest_body zx.meta matches 1 run return 0
execute if entity @s[tag=sd.fb.body] run function sweetdream:boss/aggro/redirect with storage zx:work jbody_target
execute if entity @s[tag=sd.kn.body] run function sweetdream:boss/aggro/redirect with storage zx:work jbody_target
execute if entity @s[tag=sd.hk.body] run function sweetdream:boss/aggro/redirect with storage zx:work jbody_target
scoreboard players set #jtaunt zx.meta 0
execute on target if entity @s[type=minecraft:player] run scoreboard players set #jtaunt zx.meta 1
execute if score #jtaunt zx.meta matches 1 run function sweetdream:profession/twin/taunt_native
