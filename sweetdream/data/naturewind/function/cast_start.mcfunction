# ============================================================
# naturewind/cast_start —— 播放「风行于大地之上」的释放动画
# ------------------------------------------------------------
# 【谁调用它】sweetdream:equipment/staff/wind_ontheground/skill 的第 ④ 步之后
#   （魔力已扣、冷却已记 = 施法这件事已经成立）。**刻意放在那里而不是函数末尾**：
#   skill 后面还有一处 `run return 0`（术阵已满的分支），会提前结束整个函数 ——
#   但那时候技能其实已经放出来了，动画照样该播不许被跳过。
#
# 【执行者】施法者本人
#
# 【怎么驱动的】cast_tick 每 tick 把 nw.cast_t 写进主手/副手法杖的
#   custom_model_data.floats[1]；资源包 items/staff.json 里那层
#   range_dispatch(index 1) 按这个值选 cast_00..cast_25。
#   floats[0] 仍然是原来的待机帧，不动它。
#
# 【为什么用 tag】tick 里用 @a[tag=nw.casting] 筛人 —— 没在施法的人
#   完全不参与这个函数，零开销。重复施法时先 set 再 add，不会叠加。
# ============================================================

scoreboard players set @s nw.cast_t 0
tag @s add nw.casting
