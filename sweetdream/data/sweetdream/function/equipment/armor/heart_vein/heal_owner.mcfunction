scoreboard players add @s zx.hv_hacc 0
scoreboard players operation @s zx.hv_hacc += #hv_lost zx.meta
scoreboard players operation #heal_pt zx.meta = @s zx.hv_hacc
scoreboard players operation #heal_pt zx.meta /= #1000 zx.meta
scoreboard players operation @s zx.hv_hacc %= #1000 zx.meta
execute if score #heal_pt zx.meta matches 1.. run function sweetdream:lib/heal
