function fallendream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0
$scoreboard players set #im_refund zx.meta $(total)
scoreboard players operation #im_refund zx.meta /= #10 zx.meta
data modify storage manacore:in arg set value {uuid:"",value:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute store result storage manacore:in arg.value double 0.001 run scoreboard players get #im_refund zx.meta
function manacore:api/mana/add
function fallendream:profession/mage/add_orb
# dup-ok: 注魔本次攻击链结束明确获得两个法球。
function fallendream:profession/mage/add_orb
