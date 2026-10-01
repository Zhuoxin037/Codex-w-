# ============================================================
# sweetdream:equipment/axe/charge/tick —— 超载状态的每秒心跳
# ------------------------------------------------------------
# 【执行者】处于超载状态的玩家(位置也在他身上)
# ============================================================

# ① 每秒续迅捷 II(状态结束了它自己 3 秒后就没了)
effect give @s minecraft:speed 3 1 true

# ② 对自身 8 格内**随机** 1 个生物放一次闪电
#   sort=random 每次求值都会重挑一个, 所以先打标签把它固定住再交给 bolt,
#   不然"落点"和"被劈的那只"会对不上。
tag @e[tag=zx.chg_t] remove zx.chg_t
execute at @s run tag @e[type=!#sweetdream:no_damage,distance=..8,sort=random,limit=1] add zx.chg_t
execute at @e[tag=zx.chg_t,limit=1] run function sweetdream:equipment/axe/charge/bolt
tag @e[tag=zx.chg_t] remove zx.chg_t

# ③ 倒计时(10 -> 0), 归零收尾
scoreboard players remove @s zx.chg_on 1
execute if score @s zx.chg_on matches ..0 run function sweetdream:equipment/axe/charge/end
