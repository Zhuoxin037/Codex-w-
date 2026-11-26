advancement revoke @s only fallendream:equipment/axe/no_return
execute unless score @s zx.job matches 2 run tellraw @s {"text":"当前职业无法使用这件专属装备。","color":"red"}
execute unless score @s zx.job matches 2 run return fail
execute if entity @s[tag=zx.nr_active] run return run function fallendream:equipment/axe/no_return/end
function fallendream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail
data modify storage manacore:in arg set value {uuid:"",skill:"fallendream:no_return",mana:360.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/skill/check
execute unless data storage manacore:out r{success:1b} run return fail
data modify storage manacore:in arg set value {uuid:"",value:360.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function fallendream:lib/mana/pay
execute unless data storage manacore:out r{success:1b} run return fail
data modify storage manacore:in arg set value {uuid:"",skill:"fallendream:no_return",cooldown_seconds:70.0,reduce:1b}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/cooldown/start
execute store result score #mp_src zx.meta run data get entity @s Health 1000
scoreboard players set #mp_mul zx.meta 300
function fallendream:lib/math/mul_permille
scoreboard players operation #nr_hp zx.meta = #mp_out zx.meta
data modify storage zx:work noreturn_self set value {num:0.0}
execute store result storage zx:work noreturn_self.num double .001 run scoreboard players get #nr_hp zx.meta
function fallendream:equipment/axe/no_return/self_damage with storage zx:work noreturn_self
execute store result score @s zx.nr_hp run data get entity @s Health 1000
scoreboard players operation @s zx.nr_end = #now manacore.meta
scoreboard players add @s zx.nr_end 160
scoreboard players set @s zx.nr_count 0
scoreboard players set @s zx.nr_reject -1
scoreboard players set @s zx.nr_finish 0
scoreboard players operation @s zx.nr_gen = #now manacore.meta
tag @s add zx.nr_active
