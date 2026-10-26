scoreboard players remove @s zx.j_cr_t 1
scoreboard players operation #jrem zx.meta = @s zx.j_cr_t
scoreboard players operation #jrem zx.meta %= #j20 zx.meta
execute if score #jrem zx.meta matches 0 run function sweetdream:profession/mage/crystal_pulse
