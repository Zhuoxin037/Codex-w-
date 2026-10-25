scoreboard players set #bars sdk.step 0
data modify storage sweetdream:knight bar_queue set from storage sweetdream:knight bars
execute if data storage sweetdream:knight bar_queue[0] run function sweetdream:boss/knight/bar_next
