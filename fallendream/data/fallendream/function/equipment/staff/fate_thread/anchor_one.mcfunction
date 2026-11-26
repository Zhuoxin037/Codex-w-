$execute as $(uuid) if data entity @s Health unless data entity @s {Health:0.0f} run data modify storage zx:ft frames[-1].f.anchor set value "$(uuid)"
