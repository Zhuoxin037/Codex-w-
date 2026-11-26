function fallendream:profession/stats
execute if score @s zx.job matches 1 run function fallendream:profession/mage/regen
execute if score @s zx.job matches 4 run function fallendream:profession/twin/second
execute if score @s zx.j_bloom matches 1 run function fallendream:profession/mage/bloom
scoreboard players enable @s zx.prophecy_tg

function fallendream:profession/protection_cleanup
