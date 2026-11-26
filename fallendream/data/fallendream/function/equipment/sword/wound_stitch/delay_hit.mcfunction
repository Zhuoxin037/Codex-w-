$execute unless entity @e[type=!minecraft:player,distance=0..,nbt={UUID:[I;$(t0),$(t1),$(t2),$(t3)]},limit=1] run return 0
data modify storage zx:work a set from entity @s data
$data modify storage zx:work a.target set value "@e[type=!minecraft:player,distance=0..,nbt={UUID:[I;$(t0),$(t1),$(t2),$(t3)]},limit=1]"
function fallendream:lib/num/plain
function fallendream:internal/attack/submit_extra
