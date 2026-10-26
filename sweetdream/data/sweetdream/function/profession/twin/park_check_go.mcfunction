$execute if data storage zx:jobs p."$(uuid)".twin.pos unless entity @e[tag=zx.j_shadow,distance=0..] run function sweetdream:profession/twin/died
$execute if entity @e[tag=zx.j_shadow,limit=1] run data modify storage zx:jobs p."$(uuid)".twin.hp set from entity @e[tag=zx.j_shadow,limit=1] Health
