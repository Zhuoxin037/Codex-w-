# ============================================================
# sweetdream:equipment/sword/yebu/ol_bind_sweep —— 三维度扫"移速惩罚到点"的生物(每秒一次)
# ------------------------------------------------------------
# 【谁调用它】lib/second(每次一行)
# 【成本】选择器带 tag=zx.yb_bind, 健康状态下**没有生物**满足 ⇒ 就是三次空转,
#   和 lib/unfreeze_sweep 同一套写法与同一笔开销。
# 【为什么每秒够】惩罚是 5 秒的时长, 晚摘最多 1 秒; 而"晚摘"只影响那 5 秒末尾,
#   玩家不会察觉(要精确到刻的话得放 core/tick 每刻扫全体, 那是热路径, 不值)。
# ============================================================
execute in minecraft:overworld run function sweetdream:equipment/sword/yebu/ol_bind_dim
execute in minecraft:the_nether run function sweetdream:equipment/sword/yebu/ol_bind_dim
execute in minecraft:the_end run function sweetdream:equipment/sword/yebu/ol_bind_dim
