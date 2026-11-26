scoreboard players set @s zx.eh_before 0
execute if items entity @s armor.head *[minecraft:custom_data~{zx:["eagle_hat"],ol:"eagle_hat"}] run scoreboard players operation @s zx.eh_before = @s zx.j_orb
execute if items entity @s armor.head *[minecraft:custom_data~{zx:["eagle_hat"],ol:"eagle_hat"}] run scoreboard players operation @s zx.eh_before += @s zx.j_prop
