function sweetdream:boss/fireaxe/bar_check with storage sweetdream:fireaxe bar_queue[0]
data remove storage sweetdream:fireaxe bar_queue[0]
execute if data storage sweetdream:fireaxe bar_queue[0] run function sweetdream:boss/fireaxe/bar_next
