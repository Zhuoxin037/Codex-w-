tag @a[tag=zx.j_restore_target] remove zx.j_restore_target
$execute store result score #jrestore_u0 zx.meta run data get storage manacore:players "$(uuid)".u0
$execute store result score #jrestore_u1 zx.meta run data get storage manacore:players "$(uuid)".u1
$execute store result score #jrestore_u2 zx.meta run data get storage manacore:players "$(uuid)".u2
$execute store result score #jrestore_u3 zx.meta run data get storage manacore:players "$(uuid)".u3
execute as @a if score @s manacore.u0 = #jrestore_u0 zx.meta if score @s manacore.u1 = #jrestore_u1 zx.meta if score @s manacore.u2 = #jrestore_u2 zx.meta if score @s manacore.u3 = #jrestore_u3 zx.meta run tag @s add zx.j_restore_target
execute if entity @a[tag=zx.j_restore_target,scores={zx.job=4,zx.j_form=0,zx.j_reborn=1..}] run data modify storage manacore:work a.value set value 0.0
tag @a[tag=zx.j_restore_target] remove zx.j_restore_target
