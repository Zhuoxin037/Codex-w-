scoreboard players set #bars sdh.bar 0
data modify storage sweetdream:husk bar_queue set from storage sweetdream:husk bars
execute if data storage sweetdream:husk bar_queue[0] run function sweetdream:boss/husk/bar/next
