# @s is victim, zx.ub is the attacker. Repeated applications replace old modifiers.
execute if entity @s[tag=zx.bf_strip] run function sweetdream:equipment/armor/borrow_fire/unstrip
scoreboard players set #bf_ar zx.meta 0
scoreboard players set #bf_tr zx.meta 0
execute store result score #bf_ar zx.meta run attribute @s minecraft:armor get 1000
execute store result score #bf_tr zx.meta run attribute @s minecraft:armor_toughness get 1000
execute if score #bf_ar zx.meta matches ..0 run return 0
scoreboard players set #bf_set zx.meta 0
execute as @a[tag=zx.ub,limit=1] if items entity @s armor.head *[minecraft:custom_data~{zx:["bright_candle"]}] run function sweetdream:equipment/armor/borrow_fire/check_candle
execute if score #bf_set zx.meta matches 0 run attribute @s minecraft:armor modifier add sweetdream:bf_a_dn -0.3 add_multiplied_total
execute if score #bf_set zx.meta matches 0 run attribute @s minecraft:armor_toughness modifier add sweetdream:bf_t_dn -0.5 add_multiplied_total
execute if score #bf_set zx.meta matches 1 run attribute @s minecraft:armor modifier add sweetdream:bf_a_dn -0.5 add_multiplied_total
execute if score #bf_set zx.meta matches 1 run attribute @s minecraft:armor_toughness modifier add sweetdream:bf_t_dn -0.7 add_multiplied_total
scoreboard players set #bf_after zx.meta 0
execute store result score #bf_after zx.meta run attribute @s minecraft:armor get 1000
scoreboard players operation #bf_ar zx.meta -= #bf_after zx.meta
scoreboard players set #bf_after zx.meta 0
execute store result score #bf_after zx.meta run attribute @s minecraft:armor_toughness get 1000
scoreboard players operation #bf_tr zx.meta -= #bf_after zx.meta
execute store result storage zx:work bf_transfer.armor double 0.001 run scoreboard players get #bf_ar zx.meta
execute store result storage zx:work bf_transfer.toughness double 0.001 run scoreboard players get #bf_tr zx.meta
scoreboard players operation @s zx.bf_end = #now manacore.meta
scoreboard players add @s zx.bf_end 100
tag @s add zx.bf_strip
execute as @a[tag=zx.ub,limit=1] run function sweetdream:equipment/armor/borrow_fire/strip_self with storage zx:work bf_transfer
