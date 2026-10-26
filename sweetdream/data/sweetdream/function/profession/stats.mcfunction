function sweetdream:profession/ensure
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0
scoreboard players set #jmm zx.meta 100
scoreboard players set #jat zx.meta 1
scoreboard players set #jhp zx.meta 20
scoreboard players set #jrg zx.meta 1000
execute if score @s zx.job matches 1 run scoreboard players set #jmm zx.meta 150
execute if score @s zx.job matches 1 run scoreboard players set #jhp zx.meta 10
execute if score @s zx.job matches 1 run scoreboard players set #jrg zx.meta 3000
execute if score @s zx.job matches 2 run scoreboard players set #jmm zx.meta 70
execute if score @s zx.job matches 2 run scoreboard players set #jat zx.meta 3
execute if score @s zx.job matches 2 run scoreboard players set #jrg zx.meta 500
execute if score @s zx.job matches 3 run scoreboard players set #jmm zx.meta 130
execute if score @s zx.job matches 3 run scoreboard players set #jhp zx.meta 10
execute if score @s zx.job matches 3 run scoreboard players set #jrg zx.meta 2000
execute if score @s zx.job matches 4 run scoreboard players set #jmm zx.meta 70
execute if score @s zx.job matches 4 run scoreboard players set #jhp zx.meta 16
execute if score @s zx.job matches 4 run scoreboard players set #jrg zx.meta 500
execute if score @s zx.job matches 4 if score @s zx.j_form matches 1 run scoreboard players set #jmm zx.meta 130
execute if score @s zx.job matches 4 if score @s zx.j_form matches 1 run scoreboard players set #jat zx.meta 2
execute if score @s zx.job matches 4 if score @s zx.j_form matches 1 run scoreboard players set #jhp zx.meta 5
execute if score @s zx.job matches 4 if score @s zx.j_form matches 1 run scoreboard players set #jrg zx.meta 2000
# 原版只改职业基础值，保留装备修饰符；面板用差量账本，不覆盖装备贡献。
execute store result storage zx:work jstats.mm int 1 run scoreboard players get #jmm zx.meta
execute store result storage zx:work jstats.at int 1 run scoreboard players get #jat zx.meta
execute store result storage zx:work jstats.hp int 1 run scoreboard players get #jhp zx.meta
function sweetdream:profession/stats_native with storage zx:work jstats
scoreboard players operation #jdiff zx.meta = #jmm zx.meta
scoreboard players operation #jdiff zx.meta -= @s zx.j_mm
execute unless score #jdiff zx.meta matches 0 run function sweetdream:profession/stat_max_mana
scoreboard players operation @s zx.j_mm = #jmm zx.meta
scoreboard players operation #jdiff zx.meta = #jat zx.meta
scoreboard players operation #jdiff zx.meta -= @s zx.j_at
execute unless score #jdiff zx.meta matches 0 run function sweetdream:profession/stat_base_attack
scoreboard players operation @s zx.j_at = #jat zx.meta
scoreboard players operation #jdiff zx.meta = #jhp zx.meta
scoreboard players operation #jdiff zx.meta -= @s zx.j_hp
execute unless score #jdiff zx.meta matches 0 run function sweetdream:profession/stat_max_health
scoreboard players operation @s zx.j_hp = #jhp zx.meta
scoreboard players operation #jdiff zx.meta = #jrg zx.meta
scoreboard players operation #jdiff zx.meta -= @s zx.j_rg
execute unless score #jdiff zx.meta matches 0 run function sweetdream:profession/stat_mana_regen
scoreboard players operation @s zx.j_rg = #jrg zx.meta

execute if score @s zx.job matches 1 if items entity @s armor.head *[custom_data~{zx:["eagle_hat"]}] run scoreboard players set #jhat zx.meta 200
execute unless score @s zx.job matches 1 run scoreboard players set #jhat zx.meta 0
execute unless items entity @s armor.head *[custom_data~{zx:["eagle_hat"]}] run scoreboard players set #jhat zx.meta 0
scoreboard players add @s zx.j_sel 0
scoreboard players operation #jdiff zx.meta = #jhat zx.meta
scoreboard players operation #jdiff zx.meta -= @s zx.j_sel
execute unless score #jdiff zx.meta matches 0 run function sweetdream:profession/stat_max_mana
scoreboard players operation @s zx.j_sel = #jhat zx.meta
