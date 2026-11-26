execute unless score @s zx.job matches 1 run return 0
execute unless items entity @s armor.head *[minecraft:custom_data~{zx:["eagle_hat"],ol:"eagle_hat"}] run return 0
scoreboard players add @s zx.j_orb 0
scoreboard players add @s zx.j_prop 0
scoreboard players operation #eh_change zx.meta = @s zx.j_orb
scoreboard players operation #eh_change zx.meta += @s zx.j_prop
scoreboard players operation #eh_change zx.meta -= @s zx.eh_before
execute if score #eh_change zx.meta matches 0 run return 0
data modify storage zx:work eh_events append value {amount:0,input:{},output:{},work:{}}
data modify storage zx:work eh_events[-1].input set from storage manacore:in arg
data modify storage zx:work eh_events[-1].output set from storage manacore:out r
data modify storage zx:work eh_events[-1].work set from storage manacore:work a
execute if score #eh_change zx.meta matches ..-1 run scoreboard players operation @s zx.eh_use -= #eh_change zx.meta
execute if score #eh_change zx.meta matches ..-1 run scoreboard players operation #eh_change zx.meta *= #-1 zx.meta
execute store result storage zx:work eh_events[-1].amount int 1 run scoreboard players get #eh_change zx.meta
function fallendream:equipment/armor/eagle_hat/orb_reward
execute if score @s zx.eh_use matches 10.. run scoreboard players operation @s zx.eh_indep_end = #now manacore.meta
execute if score @s zx.eh_use matches 10.. run scoreboard players add @s zx.eh_indep_end 320
execute if score @s zx.eh_use matches 10.. run scoreboard players operation @s zx.eh_use %= #10 zx.meta
data modify storage manacore:in arg set from storage zx:work eh_events[-1].input
data modify storage manacore:out r set from storage zx:work eh_events[-1].output
data modify storage manacore:work a set from storage zx:work eh_events[-1].work
data remove storage zx:work eh_events[-1]
