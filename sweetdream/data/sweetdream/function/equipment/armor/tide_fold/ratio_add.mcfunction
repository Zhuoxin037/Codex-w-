scoreboard players set #tf_carry zx.meta 0
execute if score #tf_next zx.meta >= #tf_gap zx.meta run scoreboard players set #tf_carry zx.meta 1
execute if score #tf_carry zx.meta matches 1 run scoreboard players operation #tf_next zx.meta -= #tf_gap zx.meta
execute if score #tf_carry zx.meta matches 1 run scoreboard players add #tf_digit zx.meta 1
execute if score #tf_carry zx.meta matches 0 run scoreboard players operation #tf_next zx.meta += #tf_rem zx.meta
scoreboard players remove #tf_repeat zx.meta 1
execute if score #tf_repeat zx.meta matches 1.. run function sweetdream:equipment/armor/tide_fold/ratio_add
