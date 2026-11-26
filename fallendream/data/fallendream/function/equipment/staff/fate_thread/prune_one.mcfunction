data modify storage zx:ft frames[-1].f.keep_node set value 0b
$execute if data storage zx:ft frames[-1].f.record{mode:0} at $(anchor) as $(node) if entity @s[distance=..12] if data entity @s Health unless data entity @s {Health:0.0f} run data modify storage zx:ft frames[-1].f.keep_node set value 1b
$execute if data storage zx:ft frames[-1].f.record{mode:1} at $(anchor) as $(node) if entity @s[distance=..16] if data entity @s Health unless data entity @s {Health:0.0f} run data modify storage zx:ft frames[-1].f.keep_node set value 1b
execute unless data storage zx:ft frames[-1].f{keep_node:1b} run return 0
data modify storage zx:ft frames[-1].f.keep append from storage zx:ft frames[-1].f.queue[0]
$execute as $(node) if entity @s[tag=zx.status.shixin] run data modify storage zx:ft frames[-1].f.any set value 1b
$execute at $(node) run particle minecraft:dust{color:[0.75,0.1,0.2],scale:1.0} ~ ~1 ~ 0.15 0.2 0.15 0.01 3 normal
