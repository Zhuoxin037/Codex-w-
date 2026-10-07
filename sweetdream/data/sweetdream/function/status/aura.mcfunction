# ============================================================
# sweetdream:status/aura —— 常驻状态特效(每秒一次, 三个原版维度各扫一遍)
# ------------------------------------------------------------
# 【为什么每秒、不是每刻】这些是"氛围"特效, 每秒一撮粒子就够看;
#   每刻扫全图实体的代价没必要花。
# 【为什么逐维度写三行】event/second 默认在主世界跑, 所以三个原版维度各来一遍。
# 【★ 每行都要 distance=0.. ★】裸 @e 会**跨维度**搜索 —— 三行都写裸 @e 的话粒子会撒 3 倍。
#   所以三个原版维度各来一遍(和 lib/unfreeze_sweep 一个道理)。
# 【三类状态】
#   · 圣痕(天使核心) -> 原生标签 zx.status.shenghen
#   · 升痕(天穹)     -> 计分项 zx.stg >= 1(按层数决定密度, 见 aura_stg)
#   · 电刺(电弧)     -> 原生标签 zx.status.dianci(不设时限, 见 aura_dianci)
# 【谁调用它】sweetdream:lib/second(挂在 #manacore:event/second)
# ============================================================

# 圣痕(金色, 圣洁的一柱白光)
execute in minecraft:overworld as @e[distance=0..,tag=zx.status.shenghen] at @s run function sweetdream:status/aura_shenghen
execute in minecraft:the_nether as @e[distance=0..,tag=zx.status.shenghen] at @s run function sweetdream:status/aura_shenghen
execute in minecraft:the_end as @e[distance=0..,tag=zx.status.shenghen] at @s run function sweetdream:status/aura_shenghen

# 升痕(天蓝, 层数越多越盛; 与圣痕的金色明显区分)
execute in minecraft:overworld as @e[distance=0..,scores={zx.stg=1..}] at @s run function sweetdream:status/aura_stg
execute in minecraft:the_nether as @e[distance=0..,scores={zx.stg=1..}] at @s run function sweetdream:status/aura_stg
execute in minecraft:the_end as @e[distance=0..,scores={zx.stg=1..}] at @s run function sweetdream:status/aura_stg

# 电刺(电弧, 蓝白电火花; 不设时限, 配对放电时才移除)
execute in minecraft:overworld as @e[distance=0..,tag=zx.status.dianci] at @s run function sweetdream:status/aura_dianci
execute in minecraft:the_nether as @e[distance=0..,tag=zx.status.dianci] at @s run function sweetdream:status/aura_dianci
execute in minecraft:the_end as @e[distance=0..,tag=zx.status.dianci] at @s run function sweetdream:status/aura_dianci
