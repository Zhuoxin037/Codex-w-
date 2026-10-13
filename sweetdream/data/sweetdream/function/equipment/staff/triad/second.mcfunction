# ============================================================
# sweetdream:equipment/staff/triad/second —— 强化倒计时(每秒)
# ------------------------------------------------------------
# 【谁调用它】挂进 #manacore:event/second
# 【做什么】强化中的玩家 zx.tri_strong 每秒 -1; 归零 ⇒ 切回冰斧 + 恢复被削的甲。
# 【★ 为什么"剩 1 秒时先结算再减" ★】
#   直接筛 `tri_strong = 0` 会命中**所有**没在强化的玩家(含从没用过这把武器的),
#   于是每秒都对全场玩家跑一次 strong_end(清形态、扫全场实体), 纯浪费且会误清。
#   改成"减之前, 对**正好剩 1** 的那批先结算" ⇒ 只有真的到点的才触发。
# 【★ @e 必须带 distance=0.. ★】裸 @e 在 `execute in <维度>` 下会跨维度搜全部维度,
#   三个维度各写一遍 = 同一只被处理 3 次(check 规则有这条, 2026-10-06 真实事故)。
# ============================================================

# ① 到点(剩 1 秒)的先结算: 切回冰斧 + 恢复全场被削甲的目标
execute as @a[scores={zx.tri_strong=1}] at @s run function sweetdream:equipment/staff/triad/strong_end

# ② 统一 -1
execute as @a[scores={zx.tri_strong=1..}] run scoreboard players remove @s zx.tri_strong 1
