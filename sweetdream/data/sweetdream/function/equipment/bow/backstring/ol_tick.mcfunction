# ============================================================
# sweetdream:equipment/bow/backstring/ol_tick —— 【超限】退弦的翻倍层计时
# ------------------------------------------------------------
# 【谁调用它】core/tick, 每刻对带 zx.bsb 的生物跑一遍(三维度各一行)
# 【执行者】中过退弦的那只生物
# 【只管计时, 不打伤害】伤害在 ol_bite 命中那一刻结算; 这里只负责"6 秒 / 12 秒
#   到点掉层", 所以层数一掉, 下一次命中的伤害自然回落(8 -> 16 -> 32 -> 64 -> 8)。
# 【★ 为什么不用每秒一次的 lib/second ★】文案写的是"每次翻倍持续 6 秒" ——
#   6 秒不是整秒派生的状态, 而且两套计时(6 秒 / 12 秒)要各自独立, 每刻减一最简单,
#   也避免"整秒对齐"把 6 秒变成 5~7 秒(坑 120 说的是频率≠时长, 这里就是时长)。
# 【★ 为什么可以每刻跑 ★】没有生物带 zx.bsb 时选择器全空, 开销为零; 带标签的
#   只可能是最近被射中的那几只(掉光就摘牌), 不会无限累积。
# 【★ 降为 0 才摘牌 ★】两个计时都到 0(层数都清完)才摘 zx.bsb, 否则另一套还在算。
# ============================================================

# ① 主层: 6 秒(120 刻); 只从 1 往上减, 不会减成负数
execute if score @s zx.bsb_t matches 1.. run scoreboard players remove @s zx.bsb_t 1
execute if score @s zx.bsb_t matches 0 run scoreboard players set @s zx.bsb_n 0

# ② 额外层(弦满翻出来的那一层): 12 秒(240 刻)
execute if score @s zx.bsb_xt matches 1.. run scoreboard players remove @s zx.bsb_xt 1
execute if score @s zx.bsb_xt matches 0 run scoreboard players set @s zx.bsb_x 0

# ③ 两层都没了 -> 摘牌(以后不再被 core/tick 扫到)
execute if score @s zx.bsb_n matches 0 if score @s zx.bsb_x matches 0 run tag @s remove zx.bsb
