$execute in $(dim) if entity @e[tag=zx.j_anchor,limit=1,distance=0..] run data modify storage zx:jobs p."$(uuid)".body.hp set from entity @e[tag=zx.j_anchor,limit=1,distance=0..] Health
$execute in $(dim) as @e[tag=zx.j_anchor,distance=0..] run function sweetdream:profession/twin/despawn
