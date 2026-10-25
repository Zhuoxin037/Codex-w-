scoreboard players set #hud_candle zx.meta 0
$execute as @e[tag=zx.bc_fire,distance=0..,nbt={data:{zx:{u:[I;$(u0),$(u1),$(u2),$(u3)]}}}] run scoreboard players add #hud_candle zx.meta 1
execute if score #hud_candle zx.meta matches 1.. run function sweetdream:lib/look/owned_candle
