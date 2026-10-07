# ============================================================
# sweetdream:equipment/staff/sail/whirl_tick —— 旋风的每秒心跳
# ------------------------------------------------------------
# 【谁调用它】sail/second(执行者 = 旋风 marker, at @s 位置在中心)
# 【技能原文(lore 逐字)】旋风每 3 秒都会吸引一次其 5 格内的生物并使其附加被自身
#   记录的生物的随机一种属性。…持续 15 秒。
# 【倒计时】zx.sl_p: 距下一次脉冲的秒数(3 -> 0, 归零即脉冲并重置);
#   zx.sl_t: 剩余秒数(15 -> 0, 归零 whirl_end)。
# ============================================================

# ① 每 3 秒脉冲一次
scoreboard players remove @s zx.sl_p 1
execute if score @s zx.sl_p matches ..0 run function sweetdream:equipment/staff/sail/whirl_pulse

# ② 表现 —— 不在这里画。旋风的形状是**每刻**画的(core/tick -> whirl_fx),
#   秒级函数一年只闪一次, 看不出在转。这里只管时间: 脉冲计时 + 总寿命。

# ③ 倒计时; 到 0 收尾
scoreboard players remove @s zx.sl_t 1
execute if score @s zx.sl_t matches ..0 run function sweetdream:equipment/staff/sail/whirl_end
