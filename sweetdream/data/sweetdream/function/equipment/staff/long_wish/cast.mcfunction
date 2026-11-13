advancement revoke @s only sweetdream:equipment/staff/long_wish
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail
execute if predicate sweetdream:is_sneaking run function sweetdream:equipment/staff/long_wish/skill
execute unless predicate sweetdream:is_sneaking run function sweetdream:equipment/staff/long_wish/attack
