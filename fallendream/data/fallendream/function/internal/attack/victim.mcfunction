$execute unless score @s manacore.u0 matches $(u0) run return 0
$execute unless score @s manacore.u1 matches $(u1) run return 0
$execute unless score @s manacore.u2 matches $(u2) run return 0
$execute unless score @s manacore.u3 matches $(u3) run return 0
$data modify storage zx:victim context set value {vx_uuid:"$(vx_uuid)"}
