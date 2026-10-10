# ============================================================
# sweetdream:equipment/axe/red_lotus/rain_tick —— 「持续 5 秒」的每秒驱动
# ------------------------------------------------------------
# 【谁调用它】lib/second: as @a[scores={zx.rl_rain=1..}] at @s run 本函数
# 【执行者】还有余量的施法者   【位置】他所在处
# 【计时】zx.rl_rain 起手 4(cast 已经当场发过一发, 那一发算第 1 秒),
#   每来一次发一发再 -1 -> 一共 5 发 = 5 秒。归零后 `=1..` 不再选中,
#   天然停摆, 不用额外清理。
# ============================================================

execute at @s run function sweetdream:equipment/axe/red_lotus/rain
scoreboard players remove @s zx.rl_rain 1
