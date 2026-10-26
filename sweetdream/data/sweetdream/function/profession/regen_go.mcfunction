$data modify storage zx:work ub set from storage manacore:players "$(uuid)"
function sweetdream:lib/u_by
$execute store result score #jregenmax zx.meta run data get storage manacore:players "$(uuid)".stats.max_mana 10
execute as @a[tag=zx.ub,limit=1,scores={zx.job=1}] run function sweetdream:profession/mage/regen_add
execute if entity @a[tag=zx.ub,scores={zx.job=4,zx.j_reborn=1..}] run scoreboard players set #regen manacore.math 0
