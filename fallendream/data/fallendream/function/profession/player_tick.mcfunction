execute unless score @s zx.j_init matches 1 run function fallendream:profession/stats
execute if score @s zx.deaths matches 1.. unless score @s zx.j_lastdeath = @s zx.deaths run function fallendream:profession/death
execute if score @s zx.job matches 1 run function fallendream:profession/mage/tick
execute if entity @s[tag=zx.nr_clamp] run function fallendream:equipment/axe/no_return/clamp_release
execute if entity @s[tag=zx.nr_active] run function fallendream:equipment/axe/no_return/tick
execute if score @s zx.nr_finish matches 1.. run function fallendream:equipment/axe/no_return/finish_tick
execute if score @s zx.job matches 2 run function fallendream:profession/berserker/apply
execute if score @s zx.ws_wound matches 1.. unless score @s zx.ws_until > #now manacore.meta run function fallendream:equipment/sword/wound_stitch/expire
execute if score @s zx.job matches 4 run function fallendream:profession/twin/tick
execute if score @s zx.wp_switch matches 1.. unless score @s zx.wp_until > #now manacore.meta run scoreboard players set @s zx.wp_switch 0
execute if score @s zx.job matches 4 if score @s zx.j_form matches 0 run scoreboard players operation @s zx.j_dlast = @s zx.j_dmg

function fallendream:profession/weapon_guard
