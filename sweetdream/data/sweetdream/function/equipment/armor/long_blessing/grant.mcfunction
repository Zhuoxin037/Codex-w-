# @s = 穿头盔的施法者。8 格内生命比例最低的一名受伤玩家(含自身)打擂台选出。
scoreboard players set #lb_best zx.meta 10001
tag @a[tag=zx.lb_best] remove zx.lb_best
execute at @s as @a[distance=..8] run function sweetdream:equipment/armor/long_blessing/scan
execute as @a[tag=zx.lb_best,limit=1] at @s run function sweetdream:equipment/armor/long_blessing/apply
tag @a[tag=zx.lb_best] remove zx.lb_best
