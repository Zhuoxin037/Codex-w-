function fallendream:visual/b21_icons
function fallendream:lib/uuid
scoreboard players set #s2_want_hp zx.meta 0
scoreboard players set #s2_want_atk zx.meta 0
scoreboard players set #s2_want_mana zx.meta 0
execute if items entity @s armor.chest *[custom_data~{zx:["empty_cicada"]}] run scoreboard players add #s2_want_hp zx.meta 8
execute if items entity @s armor.chest *[custom_data~{zx:["empty_cicada"]}] run scoreboard players add #s2_want_atk zx.meta 3
# 超限·空蝉：+12 / +5（基础 8/3 之上各再 +4/+2）
execute if items entity @s armor.chest *[custom_data~{zx:["empty_cicada"],ol:"empty_cicada"}] run scoreboard players add #s2_want_hp zx.meta 4
execute if items entity @s armor.chest *[custom_data~{zx:["empty_cicada"],ol:"empty_cicada"}] run scoreboard players add #s2_want_atk zx.meta 2
execute if score @s zx.job matches 2 if items entity @s armor.chest *[custom_data~{zx:["cease_war"]}] run scoreboard players add #s2_want_hp zx.meta 6
execute if score @s zx.job matches 4 if items entity @s armor.head *[custom_data~{zx:["rebirth_veil"]}] run scoreboard players add #s2_want_hp zx.meta 4
# 超限·复纱 +8(基础 4 之上再加 4)
execute if score @s zx.job matches 4 if items entity @s armor.head *[custom_data~{zx:["rebirth_veil"],ol:"rebirth_veil"}] run scoreboard players add #s2_want_hp zx.meta 4
execute if score @s zx.job matches 1 if items entity @s armor.head *[custom_data~{zx:["still_sky"]}] run scoreboard players add #s2_want_mana zx.meta 60
# 超限·静穹 +120(基础 60 之上再加 60)
execute if score @s zx.job matches 1 if items entity @s armor.head *[custom_data~{zx:["still_sky"],ol:"still_sky"}] run scoreboard players add #s2_want_mana zx.meta 60
function fallendream:batch21/apply_stats
scoreboard players set @s zx.s2_ec_hp 0
execute if items entity @s armor.chest *[custom_data~{zx:["empty_cicada"]}] run scoreboard players set @s zx.s2_ec_hp 8
execute if items entity @s armor.chest *[custom_data~{zx:["empty_cicada"],ol:"empty_cicada"}] run scoreboard players set @s zx.s2_ec_hp 12
scoreboard players set @s zx.s2_ec_atk 0
execute if items entity @s armor.chest *[custom_data~{zx:["empty_cicada"]}] run scoreboard players set @s zx.s2_ec_atk 3
execute if items entity @s armor.chest *[custom_data~{zx:["empty_cicada"],ol:"empty_cicada"}] run scoreboard players set @s zx.s2_ec_atk 5
scoreboard players set @s zx.s2_ss_mana 0
execute if score @s zx.job matches 1 if items entity @s armor.head *[custom_data~{zx:["still_sky"]}] run scoreboard players set @s zx.s2_ss_mana 60
#   超限·静穹显示 120(观测镜那行)
execute if score @s zx.job matches 1 if items entity @s armor.head *[custom_data~{zx:["still_sky"],ol:"still_sky"}] run scoreboard players set @s zx.s2_ss_mana 120
scoreboard players set @s zx.s2_cw_hp 0
execute if score @s zx.job matches 2 if items entity @s armor.chest *[custom_data~{zx:["cease_war"]}] run scoreboard players set @s zx.s2_cw_hp 6
scoreboard players set @s zx.s2_rv_hp 0
execute if score @s zx.job matches 4 if items entity @s armor.head *[custom_data~{zx:["rebirth_veil"]}] run scoreboard players set @s zx.s2_rv_hp 4
#   超限·复纱显示 8
execute if score @s zx.job matches 4 if items entity @s armor.head *[custom_data~{zx:["rebirth_veil"],ol:"rebirth_veil"}] run scoreboard players set @s zx.s2_rv_hp 8
scoreboard players set @s zx.s2_cw_armor 0
execute if entity @s[tag=zx.s2_cw] run scoreboard players set @s zx.s2_cw_armor 6
scoreboard players set @s zx.s2_cw_kb 0
execute if entity @s[tag=zx.s2_cw] run scoreboard players set @s zx.s2_cw_kb 30
