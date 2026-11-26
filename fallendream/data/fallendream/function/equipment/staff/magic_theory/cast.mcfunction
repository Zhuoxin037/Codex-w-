advancement revoke @s only fallendream:equipment/staff/magic_theory
execute unless score @s zx.job matches 1 run return fail
execute if predicate fallendream:is_sneaking run return run function fallendream:equipment/staff/magic_theory/skill
function fallendream:equipment/staff/magic_theory/attack
