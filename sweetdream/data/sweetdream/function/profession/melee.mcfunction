advancement revoke @s only sweetdream:profession/melee
function sweetdream:lib/atk_charge
execute unless score @s zx.atk_ok matches 1 run return 0
execute if score @s zx.job matches 2 run function sweetdream:profession/berserker/attack
function sweetdream:lib/victim
execute unless data storage zx:victim context.vx_uuid run return 0
data modify storage zx:work vx_frames append value {context:{}}
data modify storage zx:work vx_frames[-1].context set from storage zx:victim context
function sweetdream:profession/melee/victim_body with storage zx:work vx_frames[-1].context
data modify storage zx:victim context set from storage zx:work vx_frames[-1].context
data remove storage zx:work vx_frames[-1]
