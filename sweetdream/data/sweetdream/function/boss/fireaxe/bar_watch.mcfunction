scoreboard players set #bars sdbf.step 0
data modify storage sweetdream:fireaxe bar_queue set from storage sweetdream:fireaxe bars
execute if data storage sweetdream:fireaxe bar_queue[0] run function sweetdream:boss/fireaxe/bar_next
