# ============================================================
# sweetdream:equipment/armor/styx_walk/sea_extend —— 给一片暗海续 2 秒(不超硬上限)
# ------------------------------------------------------------
# 【谁调用它】sea_bind_one ②: `execute as @e[tag=zx.sea] if data ... run function 本函数`
#   ⇒ 执行者 @s = 那一片暗海(逐片顺序调用)
# 【文案】结附噬心时"将释放者生成的全部暗海持续时间 +2 秒" ⇒ 这里 +40 刻。
# 【硬上限】用户口径"每个暗海最多存在 10 秒"(2026-10-06) ⇒ 每片暗海出生时就记了
#   zx.sea_cap = 出生时刻 + 200, 续命只能续到 cap 为止。
#   ★ 基础寿命仍是文案值(主片 5 秒 / 次级片 3 秒), cap 只负责"封顶"。
#   ★ 不截断的后果: 多只生物反复停留 2 秒 ⇒ 每次 +2 秒, 暗海可以越续越长,
#     与"最多 10 秒"直接矛盾(还会让一片暗海长期占场)。
# 【为什么能借假玩家 #sea_cap】cap 是每片各自的值(出生时刻不同), 但本函数是
#   **逐片顺序执行**(as @e 每个实体把整个函数体跑完才轮到下一片), 用完即弃, 不会串味
#   —— RULES 坑 36 说的"共享节点串味"是**一条命令里同时处理多目标**的情形, 不是这样。
# ============================================================

scoreboard players add @s zx.sea_end 40
# 兜底: 先塞一个大值, 万一 @s 没有 zx.sea_cap 分数(比如本次更新前就已经在场上
# 的旧暗海), 下一行的 operation 会**失败并保留这个值** ⇒ 退化为"不截断", 而不是
# 把 sea_end 截到 #sea_cap 的上一轮残留值(那会让暗海凭空提前消失)。
scoreboard players set #sea_cap zx.meta 2147483647
scoreboard players operation #sea_cap zx.meta = @s zx.sea_cap
execute if score @s zx.sea_end > #sea_cap zx.meta run scoreboard players operation @s zx.sea_end = #sea_cap zx.meta
