$execute unless entity @e[tag=zx.cr_mark,nbt={data:{owner:"$(owner)"}},scores={zx.cr_layers=1..},distance=0..,limit=1] run return 0
tag @s add zx.cr_body
tag @e[tag=zx.cr_attacker,distance=0..] remove zx.cr_attacker
execute on attacker if entity @s[type=!minecraft:armor_stand] run function sweetdream:equipment/sword/contract_rift/body_source
execute at @s run function sweetdream:equipment/sword/contract_rift/clear_source
tag @s remove zx.cr_body
tag @e[tag=zx.cr_attacker,distance=0..] remove zx.cr_attacker
