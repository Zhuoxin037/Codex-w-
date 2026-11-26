$execute unless entity @e[type=!#fallendream:no_damage,nbt={UUID:[I;$(t0),$(t1),$(t2),$(t3)]},distance=0..,limit=1] run return 0
data modify storage zx:work a set from entity @s data
$data modify storage zx:work a.target set value "@e[type=!#fallendream:no_damage,nbt={UUID:[I;$(t0),$(t1),$(t2),$(t3)]},distance=0..,limit=1]"
data modify storage zx:work a.type set value "fallendream:true_damage"
data modify storage zx:work a.uncapped set value 1b
function fallendream:lib/num/plain
function fallendream:internal/attack/submit_extra
