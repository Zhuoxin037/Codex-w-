scoreboard players set @s zx.rg_tg 0
execute if entity @s[tag=zx.rg_active] run return run function sweetdream:rogue/prototype/exit
execute if entity @s[tag=zx.rg_wait] run return run function sweetdream:rogue/prototype/exit
execute if entity @s[tag=zx.rg_prep] run return run function sweetdream:rogue/prototype/exit
function sweetdream:rogue/prototype/start
scoreboard players enable @s zx.rg_tg
