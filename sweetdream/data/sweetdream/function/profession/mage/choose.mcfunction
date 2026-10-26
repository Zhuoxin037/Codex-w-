scoreboard players operation #jchoice zx.meta = @s zx.prophecy_tg
scoreboard players set @s zx.prophecy_tg 0
execute unless score @s zx.job matches 1 run return 0
execute unless score @s zx.j_pick matches 1 run return 0
execute unless score #jchoice zx.meta matches 1..3 run return 0
scoreboard players set @s zx.j_pick 0
scoreboard players set @s zx.j_pick_t 0
scoreboard players set #jchosen zx.meta 0
execute if score #jchoice zx.meta matches 1 run scoreboard players operation #jchosen zx.meta = @s zx.j_draw1
execute if score #jchoice zx.meta matches 2 run scoreboard players operation #jchosen zx.meta = @s zx.j_draw2
execute if score #jchoice zx.meta matches 3 run scoreboard players operation #jchosen zx.meta = @s zx.j_draw3
function sweetdream:profession/mage/resolve
scoreboard players remove @s zx.j_draws 1
execute if score @s zx.j_draws matches 1.. run function sweetdream:profession/mage/draw

execute unless score @s zx.j_pick matches 1 run function sweetdream:profession/mage/resistance_end
