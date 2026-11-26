$execute unless entity @e[tag=zx.s2_move_start,scores={zx.s2_move_id=$(id)},distance=3..,limit=1] run return 0
scoreboard players set @s zx.s2_step_end 0
function fallendream:lib/uuid
data modify storage zx:work cic_pos set value {owner:"",ol:0b,u0:0,u1:0,u2:0,u3:0}
data modify storage zx:work cic_pos.owner set from storage zx:data self.uuid
execute store result storage zx:work cic_pos.u0 int 1 run scoreboard players get @s manacore.u0
execute store result storage zx:work cic_pos.u1 int 1 run scoreboard players get @s manacore.u1
execute store result storage zx:work cic_pos.u2 int 1 run scoreboard players get @s manacore.u2
execute store result storage zx:work cic_pos.u3 int 1 run scoreboard players get @s manacore.u3
execute if items entity @s armor.chest *[minecraft:custom_data~{zx:["empty_cicada"],ol:"empty_cicada"}] run data modify storage zx:work cic_pos.ol set value 1b
$data modify storage zx:work cic_pos.start set from entity @e[tag=zx.s2_move_start,scores={zx.s2_move_id=$(id)},limit=1] Pos
data modify storage zx:work cic_pos.end set from entity @s Pos
$kill @e[tag=zx.s2_move_start,scores={zx.s2_move_id=$(id)},distance=0..]
function fallendream:equipment/armor/empty_cicada/release with storage zx:work cic_pos
execute if data storage zx:work cic_pos{ol:1b} if score #cic_released zx.meta matches 1.. run function fallendream:equipment/armor/empty_cicada/ol_spawn_prep
data remove storage zx:work cic_pos
