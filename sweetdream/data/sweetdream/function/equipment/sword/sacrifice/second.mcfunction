# 当前、底线、每跳损失均为毫生命。末跳先结算，再撤加成。
execute unless score @s zx.sc_on matches 1 run return 0
scoreboard players set #sc_cur zx.meta 0
execute store result score #sc_cur zx.meta run data get entity @s Health 1000
execute if score #sc_cur zx.meta <= @s zx.sc_floor run return run function sweetdream:equipment/sword/sacrifice/end
scoreboard players operation #sc_step zx.meta = @s zx.sc_dps
scoreboard players operation #sc_left zx.meta = #sc_cur zx.meta
scoreboard players operation #sc_left zx.meta -= @s zx.sc_floor
execute if score @s zx.sc_step matches 3.. run scoreboard players operation #sc_step zx.meta = #sc_left zx.meta
execute if score #sc_step zx.meta > #sc_left zx.meta run scoreboard players operation #sc_step zx.meta = #sc_left zx.meta
execute store result storage zx:work sc.v double 0.001 run scoreboard players get #sc_step zx.meta
execute if score #sc_step zx.meta matches 1.. run function sweetdream:equipment/sword/sacrifice/bleed with storage zx:work sc
scoreboard players add @s zx.sc_step 1
execute if score @s zx.sc_step matches 4.. run function sweetdream:equipment/sword/sacrifice/end
