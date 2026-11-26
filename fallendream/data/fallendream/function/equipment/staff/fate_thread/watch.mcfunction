function fallendream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0
data modify storage zx:ft frames append value {f:{owner:"",record:{},anchor:"",any:0b}}
data modify storage zx:ft frames[-1].f.owner set from storage zx:data self.uuid
function fallendream:equipment/staff/fate_thread/watch_body with storage zx:ft frames[-1].f
data remove storage zx:ft frames[-1]
