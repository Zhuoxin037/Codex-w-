# True maximum in millihitpoints, undoing only lib/heal's temporary additive cap.
scoreboard players set #max_hp zx.meta 0
scoreboard players set #heal_temp_cap zx.meta 0
execute store result score #max_hp zx.meta run attribute @s minecraft:max_health get 1000
execute if entity @s[tag=zx.heal_p] store result score #heal_temp_cap zx.meta run attribute @s minecraft:max_health modifier value get sweetdream:heal_cap 1000
execute if entity @s[tag=zx.heal_on] store result score #heal_temp_cap zx.meta run attribute @s minecraft:max_health modifier value get sweetdream:heal_cap 1000
scoreboard players operation #max_hp zx.meta -= #heal_temp_cap zx.meta
