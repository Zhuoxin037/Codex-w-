advancement revoke @s only sweetdream:equipment/sword/contract_rift_hurt
execute unless score @s zx.job matches 4 run return 0
execute unless score @s zx.j_form matches 0 run return 0
execute if score @s zx.cr_done = @s zx.hurt_total run return 0
function sweetdream:equipment/sword/contract_rift/player_track
execute unless score @s zx.cr_loss matches 1.. run return 0
scoreboard players operation @s zx.cr_done = @s zx.hurt_total
scoreboard players operation #cr_loss zx.meta = @s zx.cr_loss
function sweetdream:lib/uuid
data modify storage zx:work crguard set value {owner:"",u0:0,u1:0,u2:0,u3:0}
data modify storage zx:work crguard.owner set from storage zx:data self.uuid
execute store result storage zx:work crguard.u0 int 1 run scoreboard players get @s manacore.u0
execute store result storage zx:work crguard.u1 int 1 run scoreboard players get @s manacore.u1
execute store result storage zx:work crguard.u2 int 1 run scoreboard players get @s manacore.u2
execute store result storage zx:work crguard.u3 int 1 run scoreboard players get @s manacore.u3
tag @s add zx.cr_body
tag @e[tag=zx.cr_attacker,distance=0..] remove zx.cr_attacker
execute on attacker run function sweetdream:equipment/sword/contract_rift/body_source
tag @s remove zx.cr_body
tag @e[tag=zx.cr_attacker,distance=0..] remove zx.cr_attacker
