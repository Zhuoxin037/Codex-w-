advancement revoke @s only sweetdream:itembackup/mainhand
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

data modify storage zx:work a.uuid set from storage zx:data self.uuid
function sweetdream:internal/itembackup/mainhand_2 with storage zx:work a