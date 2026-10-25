scoreboard players set #hv_after zx.meta 0
execute store result score #hv_after zx.meta run data get entity @s Health 1000
$scoreboard players set #hv_lost zx.meta $(hp)
scoreboard players operation #hv_lost zx.meta -= #hv_after zx.meta
execute unless score #hv_lost zx.meta matches 1.. run return 0
$data modify storage zx:work ub set value {u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}
function sweetdream:lib/u_by
execute as @a[tag=zx.ub,limit=1] at @s run function sweetdream:equipment/armor/heart_vein/heal_owner
