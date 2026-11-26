data modify storage zx:ft frames[-1].f.stop set value 1b
$execute as $(main) if data entity @s Health unless data entity @s {Health:0.0f} if entity @s[tag=zx.status.shixin] run data modify storage zx:ft frames[-1].f.stop set value 0b
