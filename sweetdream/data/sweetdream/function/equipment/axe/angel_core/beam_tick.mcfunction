# ============================================================
# sweetdream:equipment/axe/angel_core/beam_tick —— 圣光柱每秒 -1, 归零 kill
# ------------------------------------------------------------
# 【谁调用它】lib/second(三维度各一行: execute in <维> as @e[tag=zx.ac_beam,distance=0..])
# 【执行者】光柱 item_display
# 【★ 与神裁/崩裂/威霆的 field_tick 同一套范式】选择器不带 type(display 也能选到);
#   计时用**秒**(和 zx.vd_ft / zx.fi_ft / zx.tc_ft 一致), 每秒一跳。
# ============================================================

# 新光柱使用独立的 40 刻动画寿命；旧版本遗留的柱子继续按原秒计时清理。
execute if score @s zx.ab_age matches 0.. run return 0
scoreboard players remove @s zx.ab_t 1
execute if score @s zx.ab_t matches ..0 run kill @s
