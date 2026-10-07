# ============================================================
# sweetdream:lib/unfreeze_sweep —— 到点就收(每秒扫一次)
# ------------------------------------------------------------
# 【★ 必须逐维度扫, 且每行都要 distance=0.. ★】裸 @e 会**跨维度**搜索 —— 三行都写裸 @e 的话,
#   同一只生物会被扫 3 次, 时停结束的事件会广播 3 遍(异彩的结束真伤跟着变 3 倍)。2026-10-06 修。
#   `distance=0..` 不过滤任何东西, 只是把搜索锁进当前维度。
#   (建议清单第 6 条)。模组维度如果以后用到, 在这里照抄一行即可。
# 【计时】冷冻看 zx.fz_end, 时停看 zx.ts_end, 各自独立。
# ============================================================

execute in minecraft:overworld run function sweetdream:lib/unfreeze_dim
execute in minecraft:the_nether run function sweetdream:lib/unfreeze_dim
execute in minecraft:the_end run function sweetdream:lib/unfreeze_dim