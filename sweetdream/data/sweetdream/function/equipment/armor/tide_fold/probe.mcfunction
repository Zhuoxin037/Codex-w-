# Current actors plus actors whose previous position was near the wall (fast motion).
tag @e[tag=zx.tf_candidate,distance=0..] remove zx.tf_candidate
execute as @e[type=!#sweetdream:no_damage,distance=..12] if data entity @s Health run tag @s add zx.tf_candidate
tag @a[distance=..12] add zx.tf_candidate
tag @e[tag=zx.ball,distance=..12] add zx.tf_candidate
execute as @e[tag=zx.tf_prev,distance=..12] run function sweetdream:equipment/armor/tide_fold/previous_candidates
execute unless entity @e[tag=zx.tf_candidate,distance=0..,limit=1] run return 0
data modify storage zx:work tf_cross set value {}
execute if data entity @s data.cross run data modify storage zx:work tf_cross set from entity @s data.cross
execute as @e[tag=zx.tf_candidate,distance=0..] run function sweetdream:equipment/armor/tide_fold/test with storage zx:work tf
data modify entity @s data.cross set from storage zx:work tf_cross
tag @e[tag=zx.tf_candidate,distance=0..] remove zx.tf_candidate
