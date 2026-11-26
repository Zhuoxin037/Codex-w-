tag @e[tag=zx.wp_target,distance=0..] remove zx.wp_target
tag @e[tag=zx.wp_area,distance=0..] remove zx.wp_area
$tag @e[type=!#fallendream:no_damage,distance=0..,nbt={UUID:[I;$(t0),$(t1),$(t2),$(t3)]},limit=1] add zx.wp_target
execute unless entity @e[tag=zx.wp_target,distance=0..,limit=1] run return 0
execute if data entity @s data{enh:1b} at @e[tag=zx.wp_target,distance=0..,limit=1] run tag @e[type=!#fallendream:no_damage,tag=!zx.wp_target,distance=..2,sort=nearest,limit=3] add zx.wp_area
tag @e[tag=zx.wp_target,distance=0..] add zx.wp_area
data modify storage zx:work a set from entity @s data
data modify storage zx:work a.target set value "@e[tag=zx.wp_area,distance=0..]"
data modify storage zx:work a.type set value "fallendream:true_damage"
data modify storage zx:work a.uncapped set value 1b
function fallendream:lib/num/plain
function fallendream:internal/attack/submit_extra
data modify storage zx:work ub set from entity @s data
function fallendream:lib/u_by
scoreboard players set #jero_pct zx.meta 60
execute if entity @a[tag=zx.ub,scores={zx.j_aw=1},distance=0..,limit=1] run scoreboard players set #jero_pct zx.meta 70
execute as @e[tag=zx.wp_area,distance=0..] at @s run function fallendream:profession/twin/erode
execute as @e[tag=zx.wp_area,distance=0..] at @s if entity @s run function fallendream:profession/twin/erode
execute if data entity @s data{enh:1b} as @e[tag=zx.wp_area,distance=0..] at @s run function fallendream:profession/twin/erode
data modify storage zx:work fz set value {target:"@e[tag=zx.wp_area,distance=0..]",ticks:10}
execute if data entity @s data{enh:1b} run data modify storage zx:work fz.ticks set value 30
execute as @a[tag=zx.ub,scores={zx.job=4},distance=0..,limit=1] run function fallendream:lib/timestop with storage zx:work fz
tag @e[tag=zx.wp_target,distance=0..] remove zx.wp_target
tag @e[tag=zx.wp_area,distance=0..] remove zx.wp_area
