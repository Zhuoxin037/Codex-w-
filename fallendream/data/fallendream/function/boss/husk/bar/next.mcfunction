function fallendream:boss/husk/bar/check with storage fallendream:husk bar_queue[0]
data remove storage fallendream:husk bar_queue[0]
execute if data storage fallendream:husk bar_queue[0] run function fallendream:boss/husk/bar/next
