advancement revoke @s only fallendream:equipment/staff/long_wish
function fallendream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail
execute if predicate fallendream:is_sneaking run function fallendream:equipment/staff/long_wish/skill
execute unless predicate fallendream:is_sneaking run function fallendream:equipment/staff/long_wish/attack
