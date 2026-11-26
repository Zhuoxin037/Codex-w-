scoreboard players set #bars sdk.step 0
data modify storage fallendream:knight bar_queue set from storage fallendream:knight bars
execute if data storage fallendream:knight bar_queue[0] run function fallendream:boss/knight/bar_next
