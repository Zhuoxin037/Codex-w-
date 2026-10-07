# ============================================================
# sweetdream:equipment/sword/myriad/domain_tick —— 领域的**每秒**推进
# ------------------------------------------------------------
# 【执行者】领域 marker(由 ol_second 以 `as @e[tag=zx.mq_f] at @s` 挑出来)
# 【现在只剩一件事】寿命 -1, 归零就撤(domain_end)。
# 【★ 画圈从这里搬走了 ★】视觉改成 domain_fx 每刻一次(挂 core/tick 三维度)。
#   每秒只画一次 = 20 fps 里只有 1 帧有点, 玩家看着就是"偶尔闪一下"
#   => 反馈"领域不明显", 而这条边界是全套机制(攻击计数 / 特殊技能窗口)
#      唯一的判据, 看不见就没法玩。逻辑(寿命)留在每秒、视觉挪到每刻 ——
#      和本包其它效果(风帆旋风 / 剑魂绕身 / 释梦入梦体)是同一套分工。
# ============================================================

scoreboard players remove @s zx.mq_ft 1
execute if score @s zx.mq_ft matches ..0 run function sweetdream:equipment/sword/myriad/domain_end
