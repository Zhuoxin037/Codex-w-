function sweetdream:profession/stats
execute if score @s zx.job matches 1 run function sweetdream:profession/mage/regen
execute if score @s zx.job matches 4 run function sweetdream:profession/twin/second
execute if score @s zx.j_bloom matches 1 run function sweetdream:profession/mage/bloom
scoreboard players enable @s zx.prophecy_tg

function sweetdream:profession/protection_cleanup
