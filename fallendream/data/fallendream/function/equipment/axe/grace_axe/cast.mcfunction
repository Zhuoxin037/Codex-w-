advancement revoke @s only fallendream:equipment/axe/grace_axe
execute unless score @s zx.ga_lux matches 1.. run return fail
function fallendream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail
data modify storage manacore:in arg set value {uuid:"",skill:"fallendream:grace_axe",mana:150.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/skill/check
execute unless data storage manacore:out r{success:1b} run return fail
data modify storage manacore:in arg set value {uuid:"",value:150.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function fallendream:lib/mana/pay
execute unless data storage manacore:out r{success:1b} run return fail
scoreboard players operation #ga_x zx.meta = @s zx.ga_lux
scoreboard players set @s zx.ga_lux 0
data modify storage manacore:in arg set value {uuid:"",skill:"fallendream:grace_axe",cooldown_seconds:30.0,reduce:1b}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/cooldown/start
execute if score #ga_x zx.meta matches 1 run effect give @e[type=!#fallendream:no_damage,distance=..1] minecraft:instant_health 1 0 true
execute if score #ga_x zx.meta matches 1 run effect give @a[distance=..1] minecraft:instant_health 1 0 true
execute if score #ga_x zx.meta matches 2 run effect give @e[type=!#fallendream:no_damage,distance=..2] minecraft:instant_health 1 1 true
execute if score #ga_x zx.meta matches 2 run effect give @a[distance=..2] minecraft:instant_health 1 1 true
execute if score #ga_x zx.meta matches 3 run effect give @e[type=!#fallendream:no_damage,distance=..3] minecraft:instant_health 1 2 true
execute if score #ga_x zx.meta matches 3 run effect give @a[distance=..3] minecraft:instant_health 1 2 true
execute if score #ga_x zx.meta matches 4 run effect give @e[type=!#fallendream:no_damage,distance=..4] minecraft:instant_health 1 3 true
execute if score #ga_x zx.meta matches 4 run effect give @a[distance=..4] minecraft:instant_health 1 3 true
execute if score #ga_x zx.meta matches 5 run effect give @e[type=!#fallendream:no_damage,distance=..5] minecraft:instant_health 1 4 true
execute if score #ga_x zx.meta matches 5 run effect give @a[distance=..5] minecraft:instant_health 1 4 true
