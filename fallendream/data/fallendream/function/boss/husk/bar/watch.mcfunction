scoreboard players set #bars sdh.bar 0
data modify storage fallendream:husk bar_queue set from storage fallendream:husk bars
execute if data storage fallendream:husk bar_queue[0] run function fallendream:boss/husk/bar/next
