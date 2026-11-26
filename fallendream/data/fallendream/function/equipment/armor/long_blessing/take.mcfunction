# @s = 当前更优(生命比例更低)的候选, 刷新擂台。
scoreboard players operation #lb_best zx.meta = #hp_p100 zx.meta
tag @a[tag=zx.lb_best] remove zx.lb_best
tag @s add zx.lb_best
