execute unless score @s zx.job matches 1 run return 0
execute unless items entity @s weapon.mainhand *[custom_data~{zx:["mana_imbue"]}] run return 0
function sweetdream:lib/uuid
execute if score @s zx.j_im_n matches 1.. run function sweetdream:profession/mage/imbue_repeat
data modify storage manacore:in arg set value {uuid:""}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/mana/get
execute store result score #jimb_m zx.meta run data get storage manacore:out r.value 1000
execute unless score #jimb_m zx.meta matches 100001.. run return 0
data modify storage manacore:in arg set value {uuid:"",value:50.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function sweetdream:lib/mana/pay
execute if data storage manacore:out r{success:1b} run function sweetdream:profession/mage/add_orb
