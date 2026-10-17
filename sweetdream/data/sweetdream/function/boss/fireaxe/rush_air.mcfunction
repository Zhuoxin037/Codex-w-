$function sweetdream:boss/fireaxe/move {step:$(step),ground:0}
execute if score @s sdbf.moved matches 0 run scoreboard players set @s sdbf.blocked 1
