# Baselines are maintained by the existing native observer, including lethal hits.
execute unless score @s zx.nh_hp matches 0.. run return 0
scoreboard players operation #atk_actual zx.meta = @s zx.nh_hp
scoreboard players operation #atk_actual zx.meta += @s zx.nh_ab
data modify storage zx:work attack_sample set from entity @s
scoreboard players set #atk_hp zx.meta 0
scoreboard players set #atk_ab zx.meta 0
execute store result score #atk_hp zx.meta run data get storage zx:work attack_sample.Health 1000
execute store result score #atk_ab zx.meta run data get storage zx:work attack_sample.AbsorptionAmount 1000
scoreboard players operation #atk_actual zx.meta -= #atk_hp zx.meta
scoreboard players operation #atk_actual zx.meta -= #atk_ab zx.meta
execute if score #atk_actual zx.meta matches ..0 run return 0
execute store result storage zx:combat input.actual int 1 run scoreboard players get #atk_actual zx.meta
data modify storage zx:combat input.valid set value 1b

data modify storage zx:combat input.was set value {}
execute if entity @s[tag=zx.status.liuhuo] run data modify storage zx:combat input.was.liuhuo set value 1b
execute if entity @s[tag=zx.status.dream] run data modify storage zx:combat input.was.dream set value 1b
scoreboard players set #hit_fire zx.meta 0
execute store result score #hit_fire zx.meta run data get storage zx:work attack_sample.Fire
execute if score #hit_fire zx.meta matches 1.. run data modify storage zx:combat input.was.burning set value 1b
