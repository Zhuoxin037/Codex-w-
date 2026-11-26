# @s = 8 格内的候选玩家。只算"受伤玩家"(生命比例未满 10000), 逐个打擂台。
function fallendream:lib/hp_pct
execute if score #hp_p100 zx.meta matches 10000 run return 0
execute if score #hp_p100 zx.meta < #lb_best zx.meta run function fallendream:equipment/armor/long_blessing/take
