# ============================================================
# sweetdream:equipment/sword/thunder_wedge/wedge_tick —— "雷楔"每秒一跳(执行者 = 雷楔 marker)
# ------------------------------------------------------------
# 【谁调用它】lib/second: execute in <维度> as @e[type=marker,tag=zx.twg_wedge,distance=0..] at @s run ...
# 【做什么】① 电力表现(看得见"楔子还立着") ② 剩余秒数 -1 ③ 归零 wedge_end
# 【为什么每秒不是每刻】只有倒计时需要走, 表现用每秒一小撮电火花足够
#   (RULES: 计时按秒、表现按刻; 这里表现也只是"持续存在"的指示, 不必每刻铺)。
# 【★ 这里没有活动目标, 所以不涉及"裸 @e 跨维度"★】
#   lib/second 已经按三维度各跑一遍 + distance=0.. 锁维度(选择器别写死 type)。
# ============================================================

# ① 表现: 楔子上半空持续冒电火花
execute at @s run particle minecraft:electric_spark ~ ~0.5 ~ 0.3 0.5 0.3 0.02 4 normal

# ② 剩余秒数 -1
scoreboard players remove @s zx.twg_ft 1

# ③ 到点收摊(8 秒)
execute if score @s zx.twg_ft matches ..0 run function sweetdream:equipment/sword/thunder_wedge/wedge_end
