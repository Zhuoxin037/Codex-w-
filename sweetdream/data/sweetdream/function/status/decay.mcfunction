# ============================================================
# sweetdream:status/decay —— 生物身上的「武器专属标签」每秒衰减
# ------------------------------------------------------------
# 【★ 范围: 只针对"贴在生物上"的武器专属标签 ★】(用户 2026-10-06 定稿, 以后照此办理)
#   · 圣痕(天使核心) -> 标签 zx.status.shenghen: 15 秒后整条消失(它只有"在不在", 没有层)
#   · 升痕(天穹)     -> 计分项 zx.stg(1..3): 每 15 秒 −1 层
#   ★ 玩家自己那套层数资源(燃灰/冰凌/梦回/悲鸣/熔浆/烈空/启示/灼烧/风声)**不在此列** ——
#     它们的时长各自归装备逻辑管(例: 燃灰的衰减在 furnace_core/passive)。
#     以后新增"贴给生物的武器标签"才挂到这里; 玩家层数不要挂。
# 【为什么每秒、不是每刻】这类标签寿命以秒计, 每秒扫一次足够。
# 【为什么逐维度写三行】event/second 默认在主世界跑, 所以三个原版维度各来一遍。
# 【★ 每行都要 distance=0.. ★】裸 @e 会**跨维度**搜索 —— 三行都写裸 @e 的话, 同一只每秒会被扣 3 点,
#   标签寿命直接变 1/3(玩家报"5 秒掉了 15 秒")。这正是 2026-10-06 修的 bug。
# 【谁调用它】sweetdream:lib/second(挂在 #manacore:event/second)
# 【计时怎么走】施加时把计时设成 15(status/decay_* 的 ① 只做"老存档兜底"),
#   之后每秒 −1, 到 0 才摘标签/掉层 —— 即"最后一次叠加后再数 15 秒开始衰减"。
# ============================================================

# 圣痕: 15 秒到点摘掉
execute in minecraft:overworld as @e[distance=0..,tag=zx.status.shenghen] at @s run function sweetdream:status/decay_shenghen
execute in minecraft:the_nether as @e[distance=0..,tag=zx.status.shenghen] at @s run function sweetdream:status/decay_shenghen
execute in minecraft:the_end as @e[distance=0..,tag=zx.status.shenghen] at @s run function sweetdream:status/decay_shenghen

# 升痕: 每 15 秒 −1 层
execute in minecraft:overworld as @e[distance=0..,scores={zx.stg=1..}] at @s run function sweetdream:status/decay_stg
execute in minecraft:the_nether as @e[distance=0..,scores={zx.stg=1..}] at @s run function sweetdream:status/decay_stg
execute in minecraft:the_end as @e[distance=0..,scores={zx.stg=1..}] at @s run function sweetdream:status/decay_stg
