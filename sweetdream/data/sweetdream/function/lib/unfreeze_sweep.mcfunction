# ============================================================
# sweetdream:lib/unfreeze_sweep —— 到点就收(每秒扫一次)
# ------------------------------------------------------------
# 【★ 必须逐维度扫 ★】@e 只覆盖**当前维度**, 所以三个原版维度各跑一遍
#   (建议清单第 6 条)。模组维度如果以后用到, 在这里照抄一行即可。
# 【计时】冷冻看 zx.fz_end, 时停看 zx.ts_end, 各自独立。
# ============================================================

execute in minecraft:overworld run function sweetdream:lib/unfreeze_dim
execute in minecraft:the_nether run function sweetdream:lib/unfreeze_dim
execute in minecraft:the_end run function sweetdream:lib/unfreeze_dim