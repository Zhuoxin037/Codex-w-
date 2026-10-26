$data modify storage zx:work jt_restore set from storage zx:jobs p."$(uuid)".body
$data modify storage zx:work jt_restore.uuid set value "$(uuid)"
function sweetdream:profession/twin/restore_body_read with storage zx:work jt_restore
$data modify storage zx:work jt_dest set from storage zx:jobs p."$(uuid)".body
function sweetdream:profession/twin/tp with storage zx:work jt_dest
$execute store result score #jhpnew zx.meta run data get storage zx:jobs p."$(uuid)".body.hp 1000
function sweetdream:profession/twin/set_health
$data modify storage manacore:players "$(uuid)".stats.current_mana set from storage zx:jobs p."$(uuid)".body.mana
