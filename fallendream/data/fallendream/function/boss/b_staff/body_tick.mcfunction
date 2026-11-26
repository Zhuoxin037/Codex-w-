execute store result score @s bs.hp run data get entity @s Health 1000
execute if entity @s[nbt={Health:0.0f}] run return run function fallendream:boss/b_staff/body_dead
tag @s add sd.bs.current_body
execute store result storage fallendream:b_staff args.id int 1 run scoreboard players get @s bs.id
scoreboard players add @s bs.bar 1
execute if score @s bs.bar matches 20.. run function fallendream:boss/b_staff/bar/update with storage fallendream:b_staff args
execute if entity @s[tag=zx.stop] run return run function fallendream:boss/b_staff/freeze
execute if score @s bs.freeze matches 1 run function fallendream:boss/b_staff/thaw
scoreboard players add @s bs.clock 1
scoreboard players set @s bs.reacted 0
execute if score @s bs.hp < @s bs.lastHP run function fallendream:boss/b_staff/react
scoreboard players operation @s bs.lastHP = @s bs.hp
function fallendream:boss/b_staff/target/tick
execute if score @s bs.cd matches 1.. run scoreboard players remove @s bs.cd 1
execute if score @s bs.reacted matches 1 run return run function fallendream:boss/b_staff/render_end
execute if score @s bs.state matches 0 run function fallendream:boss/b_staff/idle
execute if score @s bs.state matches 1..99 run function fallendream:boss/b_staff/action
function fallendream:boss/b_staff/render_end
