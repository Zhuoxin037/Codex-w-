function fallendream:boss/fireaxe/bar_check with storage fallendream:fireaxe bar_queue[0]
data remove storage fallendream:fireaxe bar_queue[0]
execute if data storage fallendream:fireaxe bar_queue[0] run function fallendream:boss/fireaxe/bar_next
