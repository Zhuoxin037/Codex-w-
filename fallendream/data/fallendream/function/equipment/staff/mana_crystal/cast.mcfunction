advancement revoke @s only fallendream:equipment/staff/mana_crystal
execute unless score @s zx.job matches 1 run tellraw @s {"text":"当前职业无法使用这件专属装备。","color":"red"}
execute unless score @s zx.job matches 1 run return fail
function fallendream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail
execute if predicate fallendream:is_sneaking run function fallendream:equipment/staff/mana_crystal/skill
execute unless predicate fallendream:is_sneaking run function fallendream:equipment/staff/mana_crystal/attack
