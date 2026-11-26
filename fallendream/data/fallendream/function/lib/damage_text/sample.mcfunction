data modify storage zx:work dt_sample set from entity @s
execute store result score @s zx.dt_hp run data get storage zx:work dt_sample.Health 1000
scoreboard players set @s zx.dt_ab 0
execute if data storage zx:work dt_sample.AbsorptionAmount store result score @s zx.dt_ab run data get storage zx:work dt_sample.AbsorptionAmount 1000
