function sweetdream:visual/b21_icons
function sweetdream:lib/uuid
scoreboard players set #s2_want_hp zx.meta 0
scoreboard players set #s2_want_atk zx.meta 0
scoreboard players set #s2_want_mana zx.meta 0
execute if items entity @s armor.chest *[custom_data~{zx:["empty_cicada"]}] run scoreboard players add #s2_want_hp zx.meta 8
execute if items entity @s armor.chest *[custom_data~{zx:["empty_cicada"]}] run scoreboard players add #s2_want_atk zx.meta 3
execute if score @s zx.job matches 2 if items entity @s armor.chest *[custom_data~{zx:["cease_war"]}] run scoreboard players add #s2_want_hp zx.meta 6
execute if score @s zx.job matches 4 if items entity @s armor.head *[custom_data~{zx:["rebirth_veil"]}] run scoreboard players add #s2_want_hp zx.meta 4
execute if score @s zx.job matches 1 if items entity @s armor.head *[custom_data~{zx:["still_sky"]}] run scoreboard players add #s2_want_mana zx.meta 60
function sweetdream:batch21/apply_stats
scoreboard players set @s zx.s2_ec_hp 0
execute if items entity @s armor.chest *[custom_data~{zx:["empty_cicada"]}] run scoreboard players set @s zx.s2_ec_hp 8
scoreboard players set @s zx.s2_ec_atk 0
execute if items entity @s armor.chest *[custom_data~{zx:["empty_cicada"]}] run scoreboard players set @s zx.s2_ec_atk 3
scoreboard players set @s zx.s2_ss_mana 0
execute if score @s zx.job matches 1 if items entity @s armor.head *[custom_data~{zx:["still_sky"]}] run scoreboard players set @s zx.s2_ss_mana 60
scoreboard players set @s zx.s2_cw_hp 0
execute if score @s zx.job matches 2 if items entity @s armor.chest *[custom_data~{zx:["cease_war"]}] run scoreboard players set @s zx.s2_cw_hp 6
scoreboard players set @s zx.s2_rv_hp 0
execute if score @s zx.job matches 4 if items entity @s armor.head *[custom_data~{zx:["rebirth_veil"]}] run scoreboard players set @s zx.s2_rv_hp 4
scoreboard players set @s zx.s2_cw_armor 0
execute if entity @s[tag=zx.s2_cw] run scoreboard players set @s zx.s2_cw_armor 6
scoreboard players set @s zx.s2_cw_kb 0
execute if entity @s[tag=zx.s2_cw] run scoreboard players set @s zx.s2_cw_kb 30
