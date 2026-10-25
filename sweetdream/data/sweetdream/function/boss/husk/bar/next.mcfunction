function sweetdream:boss/husk/bar/check with storage sweetdream:husk bar_queue[0]
data remove storage sweetdream:husk bar_queue[0]
execute if data storage sweetdream:husk bar_queue[0] run function sweetdream:boss/husk/bar/next
