$execute unless entity @e[tag=zx.s2_move_start,scores={zx.s2_move_id=$(id)},distance=3..,limit=1] run return 0
scoreboard players set @s zx.s2_step_end 0
$kill @e[tag=zx.s2_move_start,scores={zx.s2_move_id=$(id)},distance=0..]
data modify storage zx:work s2_shadow set value {owner:""}
function sweetdream:lib/uuid
data modify storage zx:work s2_shadow.owner set from storage zx:data self.uuid
function sweetdream:equipment/armor/empty_cicada/release with storage zx:work s2_shadow
