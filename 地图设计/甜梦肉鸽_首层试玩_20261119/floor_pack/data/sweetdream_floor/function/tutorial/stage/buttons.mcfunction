execute unless block -100 90 49 minecraft:polished_blackstone_button[powered=true] run scoreboard players set #edu_next sd.floor 0
execute if block -100 90 49 minecraft:polished_blackstone_button[powered=true] if score #edu_next sd.floor matches 0 run function sweetdream_floor:tutorial/stage/next
execute unless block -103 90 46 minecraft:stone_button[powered=true] run scoreboard players set #edu_back sd.floor 0
execute if block -103 90 46 minecraft:stone_button[powered=true] if score #edu_back sd.floor matches 0 run function sweetdream_floor:tutorial/stage/back
