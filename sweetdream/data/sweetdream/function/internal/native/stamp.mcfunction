data modify storage zx:work nh_snapshot set from entity @s
execute store result score @s zx.nh_hp run data get storage zx:work nh_snapshot.Health 1000
scoreboard players set @s zx.nh_ab 0
scoreboard players set @s zx.nh_stamp 0
execute if data storage zx:work nh_snapshot.AbsorptionAmount store result score @s zx.nh_ab run data get storage zx:work nh_snapshot.AbsorptionAmount 1000
execute if data storage zx:work nh_snapshot.ticks_since_last_hurt_by_mob store result score @s zx.nh_stamp run data get storage zx:work nh_snapshot.ticks_since_last_hurt_by_mob
