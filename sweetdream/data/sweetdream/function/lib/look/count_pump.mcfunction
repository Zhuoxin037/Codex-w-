scoreboard players set #hud_pump zx.meta 0
$scoreboard players set #hud_u0 zx.meta $(u0)
$scoreboard players set #hud_u1 zx.meta $(u1)
$scoreboard players set #hud_u2 zx.meta $(u2)
$scoreboard players set #hud_u3 zx.meta $(u3)
execute as @e[tag=zx.hv_pump,distance=0..] if score @s zx.hv_u0 = #hud_u0 zx.meta if score @s zx.hv_u1 = #hud_u1 zx.meta if score @s zx.hv_u2 = #hud_u2 zx.meta if score @s zx.hv_u3 = #hud_u3 zx.meta run scoreboard players add #hud_pump zx.meta 1
execute if score #hud_pump zx.meta matches 1.. run function sweetdream:lib/look/owned_pump
