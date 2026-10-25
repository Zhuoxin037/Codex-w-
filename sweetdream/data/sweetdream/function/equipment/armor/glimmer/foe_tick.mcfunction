# ============================================================
# sweetdream:equipment/armor/glimmer/foe_tick —— 减速倒计时 / 到期摘干净
# ------------------------------------------------------------
# 【执行者】@s = 带 zx.gl_sl 的生物（由 core/tick 三维度各扫一遍）
# 【为什么要有它】给生物挂 attribute 是**实体数据**, 不摘就永久生效。
#   玩家脱掉浮光、走出 10 格、或换目标之后, 那边没人负责摘 —— 靠这个倒计时兜底。
# 【★ 2 秒缓冲 ★】foe_one 每次刷到就把 zx.gl_slt 重设 40; 这里每刻 -1。
#   连续 2 秒没被刷到才真正摘掉, 避免"进出边界反复 add/remove"把 chunk 标脏。
# ============================================================

scoreboard players remove @s zx.gl_slt 1
execute if score @s zx.gl_slt matches 1.. run return 0

# 到期：两档都按账本摘（只有挂着的那档能摘成功, 另一条会失败但已在末尾, 无影响）
execute if score @s zx.gl_fv matches 40 run attribute @s minecraft:movement_speed modifier remove sweetdream:gl_slow40
execute if score @s zx.gl_fv matches 45 run attribute @s minecraft:movement_speed modifier remove sweetdream:gl_slow45
scoreboard players set @s zx.gl_fv 0
scoreboard players set @s zx.gl_slt 0
tag @s remove zx.gl_sl
