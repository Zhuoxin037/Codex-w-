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

# ② 超限: 对范围内带 DoT 的生物结算这一秒
#   ★ 排在倒计时**之前** ★ 先打这一秒的伤害、再减寿命。
#     反过来写的话，寿命归零那一秒会先 kill 掉自己、这一跳永远漏掉。
execute if entity @s[tag=zx.twg_ol] run function sweetdream:equipment/sword/thunder_wedge/ol_tick

# ③ 剩余秒数 -1
scoreboard players remove @s zx.twg_ft 1

# ④ 到点收摊(原版 8 秒 / 超限 10 秒)
#   ★ 先打 zx.twg_end 临时标签 ★ 只有"自然到期"才炸那场收尾落雷;
#     cast ⑧ 收掉旧雷楔(换一个重放)时不该炸 —— 那不是"结束后"。
execute if score @s zx.twg_ft matches ..0 run tag @s add zx.twg_end
execute if score @s zx.twg_ft matches ..0 run function sweetdream:equipment/sword/thunder_wedge/wedge_end
