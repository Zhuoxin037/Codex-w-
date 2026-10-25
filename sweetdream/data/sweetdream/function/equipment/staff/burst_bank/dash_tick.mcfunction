function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run scoreboard players set @s zx.bb_on 0
execute unless data storage zx:data self{ok:1b} run return 0
data remove storage zx:work bb
data modify storage zx:work owner_arg set from storage zx:data self
function sweetdream:equipment/staff/burst_bank/load with storage zx:work owner_arg
execute unless data storage zx:work bb.uuid run scoreboard players set @s zx.bb_on 0
execute unless data storage zx:work bb.uuid run return 0
function sweetdream:equipment/staff/burst_bank/steps with storage zx:work bb
execute if score @s zx.bb_left matches ..0 at @s run function sweetdream:equipment/staff/burst_bank/land
