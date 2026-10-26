$execute if items entity @s $(hand) *[custom_data~{j_protect:1b}] run return run item modify entity @s $(hand) {function:"minecraft:set_count",count:1,add:true}
$execute if items entity @s $(hand) * run return 0
function sweetdream:lib/uuid
data modify storage zx:work jg_restore.uuid set from storage zx:data self.uuid
$data modify storage zx:work jg_restore.key set value "$(key)"
function sweetdream:profession/twin/restore_guard_stack with storage zx:work jg_restore
$execute if items entity @e[tag=zx.j_item_tmp,limit=1] weapon.mainhand * run item replace entity @s $(hand) from entity @e[tag=zx.j_item_tmp,limit=1] weapon.mainhand
