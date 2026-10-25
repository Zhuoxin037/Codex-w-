data modify storage zx:work a set value {channel_atk:0.0,target:"@e[type=!#sweetdream:no_damage,distance=..3]",type:"sweetdream:skill"}
$data modify storage zx:work a.num set value $(ld)
function sweetdream:lib/num/plain
execute if data storage zx:config damage_type run data modify storage zx:work a.type set from storage zx:config damage_type
$data modify storage zx:work a.u0 set value $(u0)
$data modify storage zx:work a.u1 set value $(u1)
$data modify storage zx:work a.u2 set value $(u2)
$data modify storage zx:work a.u3 set value $(u3)
function sweetdream:internal/damage/with_from with storage zx:work a
tag @e[type=!#sweetdream:no_damage,distance=..3] add zx.bb_blast
execute as @e[tag=zx.bb_blast,distance=..3] at @s run function sweetdream:equipment/staff/burst_bank/push
tag @e[tag=zx.bb_blast,distance=..6] remove zx.bb_blast
particle minecraft:dust{color:[0.25,0.65,0.9],scale:1.4} ~ ~0.2 ~ 2.8 0.2 2.8 0.02 30 normal
