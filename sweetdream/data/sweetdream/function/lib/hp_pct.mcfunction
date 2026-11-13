# 精确读取毫生命；出参万分比，满血10000。四位长除避免高生命乘法溢出。
function sweetdream:lib/max_health_score
scoreboard players set #hp_rem zx.meta 0
execute store result score #hp_rem zx.meta run data get entity @s Health 1000
scoreboard players set #hp_p100 zx.meta 0
execute unless score #max_hp zx.meta matches 1.. run return 0
execute if score #hp_rem zx.meta >= #max_hp zx.meta run return run scoreboard players set #hp_p100 zx.meta 10000
# dup-ok: 万分比长除的四个小数位
function sweetdream:lib/math/hp_digit
# dup-ok: 万分比长除的四个小数位
function sweetdream:lib/math/hp_digit
# dup-ok: 万分比长除的四个小数位
function sweetdream:lib/math/hp_digit
# dup-ok: 万分比长除的四个小数位
function sweetdream:lib/math/hp_digit
