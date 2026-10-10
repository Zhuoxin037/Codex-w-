# ============================================================
# sweetdream:lib/freeze_hold —— 每 tick 帮被冻住的生物续上冻结(由 core/tick 调用)
# ------------------------------------------------------------
# 【执行者】带 zx.freeze 标签的生物
# 【为什么需要它】TicksFrozen 每 tick 会自己 -2(离开粉雪就衰减),
#   只写一次的话"冻 40 tick"会变成"冻 70 tick 里的前一段", 时长不受控 ——
#   所以每 tick 补回 140(= 完全冻结的阈值), 这样写多少 tick 就是多少 tick。
# 【开销】只对"被冻住的生物"跑; 场上没有冻住的东西时, 这个选择器是空的, 开销为零。
# ============================================================

data modify entity @s TicksFrozen set value 140

# ★ 到期就当场解冻(2026-10-08 加) ★
#   原本只有 lib/unfreeze_sweep 每秒扫一次 —— 于是"冻 3 秒"实际是
#   "3 秒 ~ 4 秒之间某个时刻才解", 玩家体感就是"明明写的 3 秒, 怎么这么久"。
#   这里本来就每 tick 在跑(上面补 TicksFrozen), 顺手判一下到点即可, 精度到 tick。
#   (unfreeze_sweep 那条每秒的兜底留着, 两边都判不冲突: 解完会摘掉 zx.freeze。)
execute if score @s zx.fz_end <= #now manacore.meta run function sweetdream:lib/unfreeze_one
#   【兜底】带了 zx.freeze 却没有 zx.fz_end 的(计时被外力清掉、或在旧版本里被写坏过):
#     上面那行的 `<=` 会因为"分数不存在"而失败, 它就永远解不开、永远走不动。
#     (时停那边 unfreeze_dim 早就有同款兜底; 冷冻这边 2026-10-09 补。)
#     判据 = "自己不等于自己"; 上一行已经解掉的话标签没了, 这里自然不会再跑一遍。
execute if entity @s[tag=zx.freeze] unless score @s zx.fz_end = @s zx.fz_end run function sweetdream:lib/unfreeze_one
