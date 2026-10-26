$execute in $(dim) if entity @e[tag=zx.j_anchor,limit=1,distance=0..] run data modify storage zx:jobs p."$(uuid)".body.hp set from entity @e[tag=zx.j_anchor,limit=1,distance=0..] Health
$execute in $(dim) run kill @e[tag=zx.j_anchor,distance=0..]
