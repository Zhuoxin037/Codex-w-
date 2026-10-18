scoreboard players operation @s sdbf.lbudget += @s sdbf.ltotal
scoreboard players operation @s sdbf.lmove = @s sdbf.lbudget
scoreboard players operation @s sdbf.lmove /= @s sdbf.lticks
scoreboard players operation @s sdbf.lbudget %= @s sdbf.lticks
execute if score @s sdbf.lmove matches 1.. if score @s sdbf.blocked matches 0 at @s run function sweetdream:boss/fireaxe/leap/substep
