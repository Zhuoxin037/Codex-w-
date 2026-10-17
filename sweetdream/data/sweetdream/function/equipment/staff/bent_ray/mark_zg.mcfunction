# ============================================================
# sweetdream:equipment/staff/bent_ray/mark_zg —— 给一只生物附加(刷新)「折光」
# ------------------------------------------------------------
# 【谁调用它】ball_hit ①(逐只)   【执行者】**被命中的生物**
# 【时长】15 秒 = 300 刻(用户 2026-10-17 拍板); 重复命中**刷新**, 不叠加。
# 【记法】zx.br_gl = 到期绝对刻; 判定一律 `if score @s zx.br_gl > #now`。
#   用绝对刻而不是"每秒 -1": 不需要 lib/second 参与, 也不会被别的系统打断。
# ============================================================

tag @s add zx.br_g
scoreboard players operation @s zx.br_gl = #now manacore.meta
scoreboard players add @s zx.br_gl 300
particle minecraft:end_rod ~ ~1 ~ 0.2 0.3 0.2 0.02 6 normal
