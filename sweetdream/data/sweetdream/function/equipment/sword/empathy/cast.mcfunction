advancement revoke @s only sweetdream:equipment/sword/empathy
execute unless score @s zx.job matches 4 run tellraw @s {"text":"当前职业无法使用这件专属装备。","color":"red"}
execute unless score @s zx.job matches 4 run return fail
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail
function sweetdream:equipment/sword/empathy/skill
