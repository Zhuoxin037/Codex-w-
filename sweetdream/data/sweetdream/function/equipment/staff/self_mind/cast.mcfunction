advancement revoke @s only sweetdream:equipment/staff/self_mind
execute unless score @s zx.job matches 4 run tellraw @s {"text":"当前职业无法使用这件专属装备。","color":"red"}
execute unless score @s zx.job matches 4 run return fail
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail
execute if predicate sweetdream:is_sneaking run function sweetdream:equipment/staff/self_mind/skill
execute unless predicate sweetdream:is_sneaking run function sweetdream:equipment/staff/self_mind/attack
