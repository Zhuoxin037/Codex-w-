execute unless score @s zx.nr_end > #now manacore.meta run function sweetdream:equipment/axe/no_return/end
execute if entity @s[tag=zx.nr_active] run data modify storage zx:work nr_tick_player set from entity @s
execute if entity @s[tag=zx.nr_active] if data storage zx:work nr_tick_player.active_effects[{id:"minecraft:instant_health"}] run effect clear @s minecraft:instant_health
execute if entity @s[tag=zx.nr_active] run function sweetdream:equipment/axe/no_return/lock_health_cached
execute if entity @s[tag=zx.nr_active,tag=!zx.nr_clamp] run function sweetdream:equipment/axe/no_return/prevent_healing
