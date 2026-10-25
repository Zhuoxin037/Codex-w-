# First post_attack entry: immutable victim/event snapshot; no world search for the attacker.
data remove storage zx:work rt
execute unless entity @s[type=player] run return 0
execute unless items entity @s weapon.offhand *[minecraft:custom_data~{zx:["retro_shine"]}] run return 0
execute unless score @s zx.hurt_at = #now manacore.meta run return 0
execute unless score @s zx.hurt_evt matches 1.. run return 0
execute if score @s zx.rt_cd > #now manacore.meta run return 0
data modify storage zx:work rt set value {num:0.0,type:"sweetdream:true_damage",target:"@s",fixed:1b}
scoreboard players operation #rt_d zx.meta = @s zx.hurt_evt
scoreboard players operation #rt_d zx.meta *= #3 zx.meta
scoreboard players operation #rt_d zx.meta /= #10 zx.meta
execute if score #rt_d zx.meta matches 12001.. run scoreboard players set #rt_d zx.meta 12000
execute store result storage zx:work rt.num double 0.001 run scoreboard players get #rt_d zx.meta
data modify storage zx:work rt.u0 set from entity @s UUID[0]
data modify storage zx:work rt.u1 set from entity @s UUID[1]
data modify storage zx:work rt.u2 set from entity @s UUID[2]
data modify storage zx:work rt.u3 set from entity @s UUID[3]
scoreboard players operation @s zx.rt_cd = #now manacore.meta
scoreboard players add @s zx.rt_cd 40
