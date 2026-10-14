scoreboard players set @s zx.an_pull 0
execute if entity @s[tag=zx.av_cast] run function sweetdream:equipment/axe/anchor/visual/end

function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0
data modify storage zx:anchor key set value {uuid:""}
data modify storage zx:anchor key.uuid set from storage zx:data self.uuid
function sweetdream:equipment/axe/anchor/cancel_owner with storage zx:anchor key
