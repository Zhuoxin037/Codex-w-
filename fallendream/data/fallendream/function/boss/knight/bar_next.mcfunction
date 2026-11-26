function fallendream:boss/knight/bar_check with storage fallendream:knight bar_queue[0]
data remove storage fallendream:knight bar_queue[0]
execute if data storage fallendream:knight bar_queue[0] run function fallendream:boss/knight/bar_next
