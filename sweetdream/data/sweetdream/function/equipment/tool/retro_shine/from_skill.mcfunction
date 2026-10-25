$execute unless entity @a[scores={manacore.u0=$(u0),manacore.u1=$(u1),manacore.u2=$(u2),manacore.u3=$(u3)}] run return 0
function sweetdream:equipment/tool/retro_shine/on_hurt
$execute if data storage zx:work rt.num as @a[scores={manacore.u0=$(u0),manacore.u1=$(u1),manacore.u2=$(u2),manacore.u3=$(u3)},limit=1] run function sweetdream:equipment/tool/retro_shine/reflect
data remove storage zx:work rt
