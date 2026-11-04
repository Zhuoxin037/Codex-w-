advancement revoke @s only sweetdream:equipment/staff/chorus
execute unless score @s zx.job matches 3 run tellraw @s {"text":"当前职业无法使用这件专属装备。","color":"red"}
execute unless score @s zx.job matches 3 run return fail
execute if predicate sweetdream:is_sneaking run function sweetdream:equipment/staff/chorus/skill
execute unless predicate sweetdream:is_sneaking run function sweetdream:equipment/staff/chorus/attack
