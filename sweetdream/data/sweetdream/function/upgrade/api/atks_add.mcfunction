# ============================================================
# sweetdream:upgrade/api/atks_add —— 攻击速度加/减差值(神经衰弱石)
# ------------------------------------------------------------
# 【入参】#diff = 差值(×100 定点, 可正可负, 例 0.1 -> 10)   【执行者】玩家
# 【只改原版属性】面板里没有"攻击速度"这一项(和 armor_add/hp_add 同一套写法)。
# 【为什么无条件先摘再加】同 id 已存在时 modifier add 会失败; 摘一个不存在的 id
#   只是返回失败(函数继续往下跑)。无条件摘才能保证"账本是多少, 属性就是多少"。
# 【账本】@s zx.up_atks —— 单位 ×100(0.1 -> 10), 是"当前已经挂上去多少"。
# 【为什么不能直接把值拼进命令】见 atks_attr 头部 —— 必须过 lib/num/plain。
# ============================================================

attribute @s minecraft:attack_speed modifier remove sweetdream:upg_atkspeed

scoreboard players operation @s zx.up_atks += #diff zx.meta
# 账本归零(脱下/换成没攻速升级的武器)时只摘不加 —— 上面的 remove 已经摘干净了。
execute if score @s zx.up_atks matches 1.. run data remove storage zx:work a
execute if score @s zx.up_atks matches 1.. run data modify storage zx:work a set value {num:0.0}
execute if score @s zx.up_atks matches 1.. store result storage zx:work a.num double 0.01 run scoreboard players get @s zx.up_atks
execute if score @s zx.up_atks matches 1.. run function sweetdream:lib/num/plain
execute if score @s zx.up_atks matches 1.. run function sweetdream:upgrade/api/atks_attr with storage zx:work a
