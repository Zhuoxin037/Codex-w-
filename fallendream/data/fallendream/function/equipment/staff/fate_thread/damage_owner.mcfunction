execute if score @s zx.ft_emitting matches 1 run return 0
execute unless entity @s[tag=zx.ft_link] run return 0
function fallendream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0
data modify storage zx:work ft_owner set from storage zx:data self
function fallendream:equipment/staff/fate_thread/has_link with storage zx:work ft_owner
execute unless score #ft_has zx.meta matches 1 run return 0
data modify storage zx:ft frames append value {f:{owner:"",source:"",actual:0,seen:{},queue:[],record:{},a:0b,b:0b}}
data modify storage zx:ft frames[-1].f.owner set from storage zx:data self.uuid
$data modify storage zx:ft frames[-1].f.source set value "$(source)"
$data modify storage zx:ft frames[-1].f.actual set value $(actual)
function fallendream:equipment/staff/fate_thread/transmit with storage zx:ft frames[-1].f
data remove storage zx:ft frames[-1]
function fallendream:equipment/staff/fate_thread/watch
