$execute unless entity @e[type=!#sweetdream:no_damage,nbt={UUID:[I;$(t0),$(t1),$(t2),$(t3)]},distance=0..,limit=1] run return 0
data modify storage zx:work a set from entity @s data
$data modify storage zx:work a.target set value "@e[type=!#sweetdream:no_damage,nbt={UUID:[I;$(t0),$(t1),$(t2),$(t3)]},distance=0..,limit=1]"
data modify storage zx:work a.type set value "sweetdream:true_damage"
data modify storage zx:work a.uncapped set value 1b
function sweetdream:lib/num/plain
function sweetdream:internal/damage/with_from with storage zx:work a
