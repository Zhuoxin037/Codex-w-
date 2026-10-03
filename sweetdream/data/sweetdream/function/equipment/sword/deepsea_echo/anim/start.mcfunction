# ============================================================
# sweetdream:equipment/sword/deepsea_echo/anim/start —— 播放「深海的回响」的释放动画
# ------------------------------------------------------------
# 【谁调用它】deepsea_echo/cast 的最后一步（魔力已扣、冷却已记、目标已标 = 施法成立）
#
# 【执行者】施法者本人
#
# 【怎么驱动的】anim/tick 每 tick 把 zx.de_cast 写进主手/副手剑的
#   custom_model_data.floats[1]；资源包 items/sword.json 里那层
#   range_dispatch(index 1) 按这个值选 cast_00..cast_31。
#
# 【为什么用 tag 筛人】core/tick 里用 @a[tag=zx.de_cast] 选 —— 没在播动画的人
#   完全不参与，开销为零。重复施法时先 set 再 add，不会叠加。
# ============================================================

scoreboard players set @s zx.de_cast 0
tag @s add zx.de_cast
