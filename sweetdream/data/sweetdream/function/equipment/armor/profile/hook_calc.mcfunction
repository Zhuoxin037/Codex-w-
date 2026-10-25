# @calc: add — the original description does not specify an independent multiplier.
execute unless entity @s[type=minecraft:player] run return 0
execute unless score @s zx.pf_mul matches 1.. run return 0
execute unless score @s zx.pf_mn matches 1.. run return 0
scoreboard players set #pfd zx.meta 0
execute store result score #pfd zx.meta run data get storage manacore:out r.damage 1000
execute if score #pfd zx.meta matches ..0 run return 0
function sweetdream:equipment/armor/profile/put_bonus
scoreboard players operation @s zx.pf_lt = #now manacore.meta
scoreboard players set @s zx.pf_mn 0
scoreboard players set @s zx.pf_mul 0
scoreboard players set @s zx.pf_mt 0
