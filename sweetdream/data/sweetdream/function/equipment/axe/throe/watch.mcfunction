$execute unless entity $(uuid) run return run kill @s
$execute unless score $(uuid) zx.pn_until > #now manacore.meta run return run kill @s
data modify storage zx:work pn_samples append from entity @s data
$execute as $(uuid) at @s run function sweetdream:equipment/axe/throe/native_loss
scoreboard players set #pn_hp zx.meta 0
$execute store result score #pn_hp zx.meta run data get entity $(uuid) Health 1000
execute store result entity @s data.hp int 1 run scoreboard players get #pn_hp zx.meta
scoreboard players set #pn_ab zx.meta 0
$execute store result score #pn_ab zx.meta run data get entity $(uuid) AbsorptionAmount 1000
execute store result entity @s data.ab int 1 run scoreboard players get #pn_ab zx.meta
data remove storage zx:work pn_samples[-1]
