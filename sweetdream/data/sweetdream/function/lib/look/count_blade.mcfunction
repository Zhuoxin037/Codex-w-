scoreboard players set #hud_blade zx.meta 0
$execute as @e[tag=zx.bb_blade,distance=0..,nbt={data:{zx:{u:[I;$(u0),$(u1),$(u2),$(u3)]}}}] run scoreboard players add #hud_blade zx.meta 1
execute if score #hud_blade zx.meta matches 1.. run function sweetdream:lib/look/owned_blade
