$execute unless entity @e[type=!minecraft:marker,distance=0..,scores={zx.sid=$(sid)},limit=1] run return run kill @s
$tp @s @e[type=!minecraft:marker,distance=0..,scores={zx.sid=$(sid)},limit=1]
