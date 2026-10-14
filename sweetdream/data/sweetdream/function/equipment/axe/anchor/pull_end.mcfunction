scoreboard players set @s zx.an_pull 0

function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0
data modify storage zx:anchor key set value {uuid:""}
data modify storage zx:anchor key.uuid set from storage zx:data self.uuid
function sweetdream:equipment/axe/anchor/pull_end_owner with storage zx:anchor key
