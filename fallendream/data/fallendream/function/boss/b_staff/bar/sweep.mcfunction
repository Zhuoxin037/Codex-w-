scoreboard players set #sweep bs.bar 0
data modify storage fallendream:b_staff bar_queue set from storage fallendream:b_staff bars
execute if data storage fallendream:b_staff bar_queue[0] run function fallendream:boss/b_staff/bar/next
