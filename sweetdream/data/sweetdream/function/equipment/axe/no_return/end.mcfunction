execute unless entity @s[tag=zx.nr_active] run return 0
function sweetdream:equipment/axe/no_return/lock_health
tag @s remove zx.nr_active
scoreboard players set @s zx.nr_end 0
scoreboard players operation @s zx.nr_finish = #now manacore.meta
scoreboard players add @s zx.nr_finish 20
function sweetdream:equipment/axe/no_return/clear_stacks
function sweetdream:profession/berserker/apply
