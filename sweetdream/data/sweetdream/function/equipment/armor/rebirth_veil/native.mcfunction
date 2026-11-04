scoreboard players set #s2_veil_before zx.meta 0
execute if score @s zx.nh_hp matches 0.. run scoreboard players operation #s2_veil_before zx.meta = @s zx.nh_hp
execute if score @s zx.nh_ab matches 0.. run scoreboard players operation #s2_veil_before zx.meta += @s zx.nh_ab
scoreboard players operation #s2_veil_before zx.meta -= #nh_hp zx.meta
scoreboard players operation #s2_veil_before zx.meta -= #nh_ab zx.meta
execute unless score #s2_veil_before zx.meta matches 1.. run return 0
data modify storage zx:work ub set from storage zx:work native_stack[-1]
function sweetdream:lib/u_by
execute as @a[tag=zx.ub,limit=1] run function sweetdream:equipment/armor/rebirth_veil/add
