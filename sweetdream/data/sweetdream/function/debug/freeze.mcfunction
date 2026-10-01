# ============================================================
# sweetdream:debug/freeze —— 看"附近的生物被冻/被时停了多久"
# ------------------------------------------------------------
# 【用法】/function sweetdream:debug/freeze
# 【它报什么】16 格内每只被冻(zx.freeze)或被时停(zx.stop)的生物: 它是谁 + 还剩几 tick
#   剩余 = 它自己的 zx.fz_end - 框架时钟 #now  (<= 0 表示下一秒就该收了)
# 【两套效果怎么区分】
#   · 冷冻 zx.freeze = 原版冻结 TicksFrozen(>=140) + 移动速度归零
#     -> 走不动, 但还能转身 / 还能攻击; 手工查:
#        /data get entity @e[type=zombie,limit=1] TicksFrozen    (>=140 = 完全冻结)
#        /attribute @e[type=zombie,limit=1] minecraft:movement_speed      (会被压到 0)
#   · 时停 zx.stop  = NoAI 完全定格(不动、不出招、动作也停); 手工查:
#        /data get entity @e[type=zombie,limit=1] NoAI           (1b = 被时停)
#   两边的到期时刻都存在同一个计分项 zx.fz_end 上, 所以剩余时间算法一样。
# 【注意】人偶这种**本来就不会动**的生物, 冻住了也看不出来 —— 想肉眼确认就用
#   僵尸 / 猪 / 苦力怕这种会走会追的: 冷冻会当场停住但还能转身, 时停连转身都没有。
# ============================================================

execute unless entity @e[tag=zx.freeze,distance=..16,limit=1] unless entity @e[tag=zx.stop,distance=..16,limit=1] run return run tellraw @s [{"text":"16 格内既没有被冻住、也没有被时停的生物","color":"red"}]

tellraw @s [{"text":"=== 冷冻中的生物(TicksFrozen + 速度归零) ===","color":"aqua","bold":true}]
execute as @e[tag=zx.freeze,distance=..16] at @s run function sweetdream:debug/freeze_one

tellraw @s [{"text":"=== 被时停的生物(NoAI 定格) ===","color":"light_purple","bold":true}]
execute as @e[tag=zx.stop,distance=..16] at @s run function sweetdream:debug/freeze_one
