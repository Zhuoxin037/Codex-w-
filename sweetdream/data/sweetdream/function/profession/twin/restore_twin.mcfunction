$execute if data storage zx:jobs p."$(uuid)".twin.pos run data modify storage zx:work jt_dest set from storage zx:jobs p."$(uuid)".twin
$execute if data storage zx:jobs p."$(uuid)".twin.pos run function sweetdream:profession/twin/tp with storage zx:work jt_dest
$execute store result score #jhpnew zx.meta run data get storage zx:jobs p."$(uuid)".twin.hp 1000
function sweetdream:profession/twin/set_health
$data modify storage manacore:players "$(uuid)".stats.current_mana set from storage zx:jobs p."$(uuid)".twin.mana
