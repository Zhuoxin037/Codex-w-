execute store result score #nr_food zx.meta run data get storage zx:work nr_tick_player.foodLevel
execute store result score #nr_foodtime zx.meta run data get storage zx:work nr_tick_player.foodTickTimer
execute store result score #nr_sat zx.meta run data get storage zx:work nr_tick_player.foodSaturationLevel 1000
execute if score #nr_food zx.meta matches 20.. if score #nr_sat zx.meta matches 1.. if score #nr_foodtime zx.meta matches 9.. run scoreboard players set #nr_prevent zx.meta 1
execute if score #nr_food zx.meta matches 18..19 if score #nr_foodtime zx.meta matches 79.. run scoreboard players set #nr_prevent zx.meta 1
execute if score #nr_food zx.meta matches 20.. if score #nr_sat zx.meta matches ..0 if score #nr_foodtime zx.meta matches 79.. run scoreboard players set #nr_prevent zx.meta 1
