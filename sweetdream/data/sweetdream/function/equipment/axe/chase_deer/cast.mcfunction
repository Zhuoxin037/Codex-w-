advancement revoke @s only sweetdream:equipment/axe/chase_deer
execute unless score @s zx.job matches 2 run return fail
execute if score @s zx.s2_stage_end > #now manacore.meta if score @s zx.s2_stage matches 1 run return run function sweetdream:equipment/axe/chase_deer/second
execute if score @s zx.s2_stage_end > #now manacore.meta if score @s zx.s2_stage matches 2 run return run function sweetdream:equipment/axe/chase_deer/third
function sweetdream:equipment/axe/chase_deer/first
