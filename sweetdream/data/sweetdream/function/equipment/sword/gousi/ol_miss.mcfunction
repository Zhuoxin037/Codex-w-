# ============================================================
# sweetdream:equipment/sword/gousi/ol_miss —— 超限·钩丝 没拉到(宏)
# ------------------------------------------------------------
# 【执行者】没被拉到的那只生物
# 【宏参数】zx:work gs3 {own}
# 【结算】最大魔力值 ×0.08 的伤害 + 施法者「下一次技能伤害 +10%」
# 【什么时候会走到这里】只有"12 步走完还没进 2 格、也没撞墙"—— 8 格锁敌半径
#   × 0.8 格/步 × 12 步 = 9.6 格, 正常永远不会超时; 真触发通常是目标被别的
#   东西顶住了(摔落 / 水流 / 被别的实体挤开)。
# ============================================================

# ① 伤害: 最大魔力 ×0.08
scoreboard players set #gs_k zx.meta 8
function sweetdream:equipment/sword/gousi/ol_hit

# ② 加成: 只保下一次(已经挂着三次的话不降级, 见 ol_buff_miss)
execute as @e[tag=zx.gs3_src,limit=1] run function sweetdream:equipment/sword/gousi/ol_buff_miss

# ③ 表现(烟 = "脱钩") + 摘标签
execute at @s run particle minecraft:smoke ~ ~0.8 ~ 0.3 0.4 0.3 0.01 10 normal
$tag @s remove zx.gs3_$(own)
