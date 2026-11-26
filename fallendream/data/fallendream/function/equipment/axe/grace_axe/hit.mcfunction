advancement revoke @s only fallendream:equipment/axe/grace_axe_hit
function fallendream:lib/atk_charge
execute unless score @s zx.atk_ok matches 1 run return 0
execute unless items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["grace_axe"]}] run return 0
execute unless score @s zx.ga_tick = @s zx.ga_tick run scoreboard players set @s zx.ga_tick -1
execute if score @s zx.ga_tick = #now manacore.meta run return 0
scoreboard players operation @s zx.ga_tick = #now manacore.meta
function fallendream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail
data modify storage manacore:in arg set value {uuid:"",skill:"fallendream:grace_axe_passive",mana:20.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/skill/check
execute unless data storage manacore:out r{success:1b} run return 0
data modify storage manacore:in arg set value {uuid:"",value:20.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function fallendream:lib/mana/pay
execute unless data storage manacore:out r{success:1b} run return 0
effect give @s minecraft:instant_health 1 0 true
scoreboard players add @s zx.ga_lux 1
execute if score @s zx.ga_lux matches 6.. run scoreboard players set @s zx.ga_lux 5
