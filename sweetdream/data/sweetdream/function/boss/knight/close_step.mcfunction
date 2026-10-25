# Reposition only during preparation; actual contact frames keep their locked sword path.
execute unless entity @e[tag=sd.kn.target,distance=1.45..,limit=1] run return 0
execute at @s run function sweetdream:boss/knight/move {step:0.3549}
