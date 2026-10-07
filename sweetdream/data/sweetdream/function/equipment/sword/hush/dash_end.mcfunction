# ============================================================
# sweetdream:equipment/sword/hush/dash_end —— 突击结束: 起归位
# ------------------------------------------------------------
# 【谁调用它】dash_tick 在"走完 / 被挡住"的那一 tick
# 【执行者】施法者本人; 【位置】他停下来的地方(还不是原点)
# 【流程(2026-10-07 改版)】
#   去程伤害已经**随碰随打**(dash_tick ③ / touch_dmg), 所以这里不再结算任何伤害;
#   只负责起归位: 交给 back_step 用约 0.2 秒(每刻 2 格)朝原点 marker 闪回去,
#   回到原点那一刻由 back_finish 结算回程伤害 ×0.2。
#   ★ 最后要清掉推进用的分数 zx.hush —— 不然 core/tick 会继续推 dash_tick。
# ============================================================

# ① 起归位: 打上"正在归位"标签 + 记倒计时(安全网; back_step 每刻 -1)
scoreboard players set @s zx.hush_bk 10
tag @s add zx.hs_back

# ② 收掉推进分数(归位由 zx.hs_back + zx.hush_bk 驱动, 不再用 zx.hush)
scoreboard players reset @s zx.hush
