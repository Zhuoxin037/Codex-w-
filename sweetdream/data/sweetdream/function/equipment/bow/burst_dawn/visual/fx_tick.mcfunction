execute if entity @s[tag=zx.bv_muzzle,scores={zx.bv_age=8..}] run return run kill @s
execute if entity @s[tag=zx.bv_impact,scores={zx.bv_age=14..}] run return run kill @s
scoreboard players add @s zx.bv_age 0
scoreboard players operation #bv_pose zx.meta = @s zx.bv_age
execute if entity @s[tag=zx.bv_muzzle] run execute store result entity @s item.components."minecraft:custom_model_data".floats[0] float 1 run scoreboard players get #bv_pose zx.meta
execute if entity @s[tag=zx.bv_impact,scores={zx.bv_age=0}] run scoreboard players set #bv_pose zx.meta 0
execute if entity @s[tag=zx.bv_impact,scores={zx.bv_age=1}] run scoreboard players set #bv_pose zx.meta 2
execute if entity @s[tag=zx.bv_impact,scores={zx.bv_age=2}] run scoreboard players set #bv_pose zx.meta 4
execute if entity @s[tag=zx.bv_impact,scores={zx.bv_age=3}] run scoreboard players set #bv_pose zx.meta 5
execute if entity @s[tag=zx.bv_impact,scores={zx.bv_age=4}] run scoreboard players set #bv_pose zx.meta 6
execute if entity @s[tag=zx.bv_impact,scores={zx.bv_age=5}] run scoreboard players set #bv_pose zx.meta 7
execute if entity @s[tag=zx.bv_impact,scores={zx.bv_age=6}] run scoreboard players set #bv_pose zx.meta 8
execute if entity @s[tag=zx.bv_impact,scores={zx.bv_age=7}] run scoreboard players set #bv_pose zx.meta 9
execute if entity @s[tag=zx.bv_impact,scores={zx.bv_age=8}] run scoreboard players set #bv_pose zx.meta 10
execute if entity @s[tag=zx.bv_impact,scores={zx.bv_age=9}] run scoreboard players set #bv_pose zx.meta 12
execute if entity @s[tag=zx.bv_impact,scores={zx.bv_age=10}] run scoreboard players set #bv_pose zx.meta 13
execute if entity @s[tag=zx.bv_impact,scores={zx.bv_age=11}] run scoreboard players set #bv_pose zx.meta 14
execute if entity @s[tag=zx.bv_impact,scores={zx.bv_age=12}] run scoreboard players set #bv_pose zx.meta 15
execute if entity @s[tag=zx.bv_impact,scores={zx.bv_age=13}] run scoreboard players set #bv_pose zx.meta 15
execute if entity @s[tag=zx.bv_impact] run execute store result entity @s item.components."minecraft:custom_model_data".floats[0] float 1 run scoreboard players get #bv_pose zx.meta
scoreboard players add @s zx.bv_age 1
