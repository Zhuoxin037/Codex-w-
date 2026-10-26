scoreboard players set #lr_hp zx.meta 0
scoreboard players set #lr_ab zx.meta 0
execute store result score #lr_hp zx.meta run data get storage zx:work lr_snapshot.Health 1000
execute if data storage zx:work lr_snapshot.AbsorptionAmount store result score #lr_ab zx.meta run data get storage zx:work lr_snapshot.AbsorptionAmount 1000
scoreboard players operation #lr_delta zx.meta = @s zx.lr_hp
scoreboard players operation #lr_delta zx.meta -= #lr_hp zx.meta
execute if score #lr_delta zx.meta matches ..0 run scoreboard players set #lr_delta zx.meta 0
scoreboard players operation #lr_abs zx.meta = @s zx.lr_ab
scoreboard players operation #lr_abs zx.meta -= #lr_ab zx.meta
execute if score #lr_abs zx.meta matches ..0 run scoreboard players set #lr_abs zx.meta 0
scoreboard players operation #lr_delta zx.meta += #lr_abs zx.meta
scoreboard players operation @s zx.lr_hp = #lr_hp zx.meta
scoreboard players operation @s zx.lr_ab = #lr_ab zx.meta
scoreboard players set #lr_cap zx.meta 2147483647
scoreboard players operation #lr_cap zx.meta -= @s zx.lr_sum
execute if score #lr_delta zx.meta > #lr_cap zx.meta run scoreboard players operation #lr_delta zx.meta = #lr_cap zx.meta
scoreboard players operation @s zx.lr_sum += #lr_delta zx.meta
