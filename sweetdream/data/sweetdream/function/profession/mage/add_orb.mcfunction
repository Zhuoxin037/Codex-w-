execute unless score @s zx.job matches 1 run return 0
function sweetdream:profession/mage/tally
execute if score #jorbs zx.meta < #jcap zx.meta run scoreboard players add @s zx.j_orb 1
