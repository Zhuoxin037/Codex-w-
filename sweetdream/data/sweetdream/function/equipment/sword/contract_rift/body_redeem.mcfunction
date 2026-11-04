scoreboard players remove @s zx.cr_layers 1
data modify storage zx:work ub set from entity @s data
function sweetdream:lib/u_by
scoreboard players set #jero_pct zx.meta 60
execute if entity @a[tag=zx.ub,scores={zx.j_aw=1},distance=0..,limit=1] run scoreboard players set #jero_pct zx.meta 70
execute as @e[tag=zx.cr_attacker,distance=0..,limit=1] at @s run function sweetdream:profession/twin/erode
execute as @e[tag=zx.cr_attacker,distance=0..,limit=1] at @s if entity @s run function sweetdream:profession/twin/erode
execute as @e[tag=zx.cr_body,type=!minecraft:player,distance=0..,limit=1] at @s run function sweetdream:equipment/sword/contract_rift/body_refund
execute as @a[tag=zx.cr_body,distance=0..,limit=1] at @s run function sweetdream:equipment/sword/contract_rift/player_refund
