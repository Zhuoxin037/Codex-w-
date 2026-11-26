data modify storage zx:work ub set from entity @s data
function fallendream:lib/u_by
execute unless entity @a[tag=zx.ub,scores={zx.job=3},distance=0..,limit=1] run return 0
data modify storage zx:work chorus set value {uuid:""}
data modify storage zx:work chorus.uuid set from entity @s data.uuid
function fallendream:equipment/staff/chorus/support_all with storage zx:work chorus
function fallendream:equipment/staff/chorus/add_echo with storage zx:work chorus
tag @e[tag=zx.cs_support,distance=0..] remove zx.cs_support
