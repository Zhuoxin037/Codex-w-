data modify storage zx:ft frames[-1].f.in_range set value 0b
$execute if data storage zx:ft frames[-1].f.record{mode:0} at $(anchor) as $(node) if entity @s[distance=..12] run data modify storage zx:ft frames[-1].f.in_range set value 1b
$execute if data storage zx:ft frames[-1].f.record{mode:1} at $(anchor) as $(node) if entity @s[distance=..16] run data modify storage zx:ft frames[-1].f.in_range set value 1b
