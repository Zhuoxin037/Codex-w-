scoreboard players remove @s zx.cr_layers 1
data modify storage zx:work cr_delay set from entity @s data
data modify storage zx:work ub set from entity @s data
function fallendream:lib/u_by
execute as @a[tag=zx.ub,scores={zx.job=4,zx.j_form=1},distance=0..,limit=1] run function fallendream:equipment/sword/contract_rift/offense_owner
