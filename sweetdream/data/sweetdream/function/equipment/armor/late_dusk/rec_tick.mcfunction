# ============================================================
# sweetdream:equipment/armor/late_dusk/rec_tick —— 记录窗口倒计时 + 到点结算
# ------------------------------------------------------------
# 【执行者】@s = 带 zx.ld_rec_on 的生物（由 core/tick 三维度各扫一遍）
# 【★ 5 秒 = 100 刻 ★】rec_open 设 100, 这里每刻 -1, 归零这一拍结算。
# ============================================================

scoreboard players remove @s zx.ld_rt 1
execute if score @s zx.ld_rt matches 1.. run return 0

# 到点：结算这一笔，然后把窗口彻底关掉
scoreboard players set @s zx.ld_rt 0
tag @s remove zx.ld_rec_on
function sweetdream:equipment/armor/late_dusk/settle
scoreboard players set @s zx.ld_rt 0
scoreboard players set @s zx.ld_rec 0
tag @s remove zx.ld_rec_on
