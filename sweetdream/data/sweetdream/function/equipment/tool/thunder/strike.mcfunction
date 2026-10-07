# ============================================================
# sweetdream:equipment/tool/thunder/strike —— 雷鸣: 抓到"新出现的一道闪电"
# ------------------------------------------------------------
# 【谁调用它】core/tick: `execute in <维度> as @e[distance=0..,
#   type=minecraft:lightning_bolt,tag=!zx.th_seen] at @s run function 本函数`
# 【执行者】那道闪电(位置 = 它自己)
# 【它做什么】"自身 6 格内的生物受到雷击后" -> 6 格内**持「雷鸣」的玩家**各自
#   登记一次"1 秒后原地再劈"(见 on_strike)。没人在场 = 空转。
# 【为什么先打 zx.th_seen】闪电实体要活好几刻(拖尾), 不打标记就会在它活着的
#   每一刻重复触发 —— 1 秒后会劈出一串闪电。
# 【★ 三维度各写一遍 + 每行 distance=0.. ★】#minecraft:tick 只在主世界跑,
#   所以三个维度要各来一遍; 而裸 @e 会跨维度搜索, distance=0.. 就是用来锁维度的
#   (它本身不过滤任何东西, 见 RULES 坑 55 / core/tick 里的说明)。
# ============================================================

tag @s add zx.th_seen
execute at @s as @a[distance=..6] if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["thunder"]}] run function sweetdream:equipment/tool/thunder/on_strike
