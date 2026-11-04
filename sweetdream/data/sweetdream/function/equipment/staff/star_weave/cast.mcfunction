advancement revoke @s only sweetdream:equipment/staff/star_weave
execute unless score @s zx.job matches 1 run tellraw @s {"text":"当前职业无法使用这件专属装备。","color":"red"}
execute unless score @s zx.job matches 1 run return fail
execute if predicate sweetdream:is_sneaking run function sweetdream:equipment/staff/star_weave/skill
execute unless predicate sweetdream:is_sneaking run function sweetdream:equipment/staff/star_weave/attack
