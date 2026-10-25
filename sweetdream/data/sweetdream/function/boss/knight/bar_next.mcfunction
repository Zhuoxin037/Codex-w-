function sweetdream:boss/knight/bar_check with storage sweetdream:knight bar_queue[0]
data remove storage sweetdream:knight bar_queue[0]
execute if data storage sweetdream:knight bar_queue[0] run function sweetdream:boss/knight/bar_next
