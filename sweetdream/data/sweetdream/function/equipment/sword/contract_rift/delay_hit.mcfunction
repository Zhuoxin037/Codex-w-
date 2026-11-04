$execute unless entity @e[type=!#sweetdream:no_damage,distance=0..,nbt={UUID:[I;$(t0),$(t1),$(t2),$(t3)]},limit=1] run return 0
data modify storage zx:work a set from entity @s data
$data modify storage zx:work a.target set value "@e[type=!#sweetdream:no_damage,distance=0..,nbt={UUID:[I;$(t0),$(t1),$(t2),$(t3)]},limit=1]"
function sweetdream:lib/num/plain
function sweetdream:internal/damage/with_from with storage zx:work a
