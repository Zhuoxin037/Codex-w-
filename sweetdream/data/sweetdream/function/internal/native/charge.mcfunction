$scoreboard players set #native_melee zx.meta $(melee)
execute unless score #native_melee zx.meta matches 1 run return 0
function sweetdream:lib/atk_charge
execute store result storage zx:work native_stack[-1].charged int 1 run scoreboard players get @s zx.atk_ok
