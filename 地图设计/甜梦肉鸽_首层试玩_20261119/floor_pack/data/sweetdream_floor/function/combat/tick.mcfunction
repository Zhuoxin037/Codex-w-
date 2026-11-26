function sweetdream_floor:combat/boundary with storage sweetdream_floor:run current
execute unless score #phase sd.floor matches 2 run return 0
execute if score #echo sd.floor matches 1.. run function sweetdream_floor:combat/echo_payout
execute unless entity @e[tag=sd.floor_enemy,distance=0..] run function sweetdream_floor:combat/win
