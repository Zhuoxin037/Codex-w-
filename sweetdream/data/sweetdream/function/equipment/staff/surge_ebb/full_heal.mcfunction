# 回满只请求当前缺失量；满血不制造溢流。lib/heal采用整点，向上取整补足小数缺口。
function sweetdream:lib/max_health_score
scoreboard players set #se_cur zx.meta 0
execute store result score #se_cur zx.meta run data get entity @s Health 1000
scoreboard players operation #se_miss zx.meta = #max_hp zx.meta
scoreboard players operation #se_miss zx.meta -= #se_cur zx.meta
execute if score #se_miss zx.meta matches ..0 run return 0
scoreboard players add #se_miss zx.meta 999
scoreboard players operation #se_miss zx.meta /= #1000 zx.meta
scoreboard players operation #heal_pt zx.meta = #se_miss zx.meta
function sweetdream:lib/heal
