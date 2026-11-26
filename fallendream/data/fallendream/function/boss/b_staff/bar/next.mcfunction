function fallendream:boss/b_staff/bar/check with storage fallendream:b_staff bar_queue[0]
data remove storage fallendream:b_staff bar_queue[0]
execute if data storage fallendream:b_staff bar_queue[0] run function fallendream:boss/b_staff/bar/next
