scoreboard players set @s zx.rg_tg 0
execute if entity @s[tag=zx.rg_active] run return run function fallendream:rogue/prototype/exit
execute if entity @s[tag=zx.rg_wait] run return run function fallendream:rogue/prototype/exit
execute if entity @s[tag=zx.rg_prep] run return run function fallendream:rogue/prototype/exit
function fallendream:rogue/prototype/start
scoreboard players enable @s zx.rg_tg
