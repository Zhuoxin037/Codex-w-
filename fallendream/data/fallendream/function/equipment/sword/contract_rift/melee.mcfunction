advancement revoke @s only fallendream:equipment/sword/contract_rift_hit
function fallendream:lib/atk_charge
execute unless score @s zx.atk_ok matches 1 run return 0
execute unless score @s zx.job matches 4 run return 0
execute unless score @s zx.j_form matches 1 run return 0
function fallendream:lib/uuid
data modify storage zx:work crhit set value {owner:"",t0:0,t1:0,t2:0,t3:0}
data modify storage zx:work crhit.owner set from storage zx:data self.uuid
function fallendream:lib/victim
execute unless data storage zx:victim context.vx_uuid run return 0
data modify storage zx:work vx_frames append value {context:{}}
data modify storage zx:work vx_frames[-1].context set from storage zx:victim context
function fallendream:equipment/sword/contract_rift/melee/victim_body with storage zx:work vx_frames[-1].context
data modify storage zx:victim context set from storage zx:work vx_frames[-1].context
data remove storage zx:work vx_frames[-1]
