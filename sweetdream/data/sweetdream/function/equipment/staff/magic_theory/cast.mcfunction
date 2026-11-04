advancement revoke @s only sweetdream:equipment/staff/magic_theory
execute unless score @s zx.job matches 1 run return fail
execute if predicate sweetdream:is_sneaking run return run function sweetdream:equipment/staff/magic_theory/skill
function sweetdream:equipment/staff/magic_theory/attack
