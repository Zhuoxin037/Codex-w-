# ============================================================
# sweetdream:equipment/armor/step_moved —— 位移已确认（只标记，不兑现）
# ------------------------------------------------------------
# 【谁调用它】lib/step ③④⑤（六个轴方向判据里任一成立）
# 【执行者】玩家
# 【★ 为什么这里不兑现踏灰 ★】踏灰的"回血 + 减冷却"要等位移**走完**才知道
#   "这次位移是哪个技能"（记录在 zx:step，step_finish 才删）—— 所以这里只置
#   zx.sm_done=1，兑现统一放到窗口末尾的 step_finish。
# 【★ 雨迹为什么在这里就撒第一点 ★】旧版等窗口结束才撒，用户看不出成没成。
#   现在确认位移的这一刻就让上一个水迹点=施法起点，并立刻调一次 sow
#   （此刻离起点已 ≥1.5 格，距离判据必然通过）⇒ 水迹跟着人走，边走边出现。
# 【★ 去重靠 zx.sm_done ★】同一刻 x 与 z 都超阈值会连调两次，第二次见到
#   done=1 直接返回。也别在这里清标签 —— 窗口还要继续跑。
# ============================================================

execute if score @s zx.sm_done matches 1 run return 0
scoreboard players set @s zx.sm_done 1

# 雨迹：第一个水迹点的基准 = 施法刻的起点（zx.sm_x/y/z 就是 step_observe 记的）
scoreboard players operation @s zx.rt_lx = @s zx.sm_x
scoreboard players operation @s zx.rt_ly = @s zx.sm_y
scoreboard players operation @s zx.rt_lz = @s zx.sm_z

# 立刻撒第一个点（不等下一刻的 lib/step，起手无延迟）
function sweetdream:equipment/armor/rain_trace/sow
