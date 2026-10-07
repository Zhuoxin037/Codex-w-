# ============================================================
# sweetdream:equipment/sword/myriad/win_tick —— 特殊技能窗口的每秒倒计时
# ------------------------------------------------------------
# 【执行者】zx.mq_win >= 1 的玩家(由 ol_second 每秒挑出来)
# 【文案】…则有 2 秒时间可以释放一次特殊技能。
#        若自身没有选择释放此次特殊技能则召唤一个相等的领域，之后召唤一个“剑魂”。
# 【★ 归零 = "没释放" ★】只要玩家在这 2 秒里放了任意一次技能, 两把刀的 cast
#   都会先把 zx.mq_win 清成 -1(见各自的 special 分支), 于是这条倒计时根本不会
#   走到 0 —— 走到 0 就说明他确实没放。
# ============================================================

scoreboard players remove @s zx.mq_win 1
execute if score @s zx.mq_win matches ..0 run function sweetdream:equipment/sword/myriad/win_expire
