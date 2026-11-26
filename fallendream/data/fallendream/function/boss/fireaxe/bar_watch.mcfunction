scoreboard players set #bars sdbf.step 0
data modify storage fallendream:fireaxe bar_queue set from storage fallendream:fireaxe bars
execute if data storage fallendream:fireaxe bar_queue[0] run function fallendream:boss/fireaxe/bar_next
