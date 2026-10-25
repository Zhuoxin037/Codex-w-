# ============================================================
# sweetdream:equipment/axe/deep_brine/ol_merge —— 超限·重溟: 领域重叠就合并
# ------------------------------------------------------------
# 【谁调用它】field_one 末行(只在超限领域刚生成之后)
# 【执行位置】新领域所在处   【执行者】施法者
# 【文案】"若领域重叠则领域合并。领域中心为随机一个被合并的领域的中心。
#         合并的领域初始为半径 8 格, 持续 6 秒。每合并一个则半径 +3 格
#         (每个合并领域最多合并 4 个)。"
# 【重叠怎么判】中心距 < 两半径之和。超限领域初始半径都是 5, 所以 10 就是判据;
#   `distance=..10` 从**新领域**位置量, 一个选择器就够。
# 【"最多合并 4 个"怎么落地】按 distance 就近取 4 个参与者(含新的自己) ——
#   超出的旧领域不参与, 留着自己活, 视觉上是"几个圈子并成一个大圈子"。
# 【半径公式】参与者 n 个 -> 8 + 3×(n-2): n=2 -> 8, n=3 -> 11, n=4 -> 14。
# 【★ 必须"先设后杀" ★】kill 掉非 keep 的那些之前要把半径/计时写到 keep 身上;
#   反过来写的话 keep 可能正好是被 kill 的那个(它是随机选的), 后面全落空。
# 【★ 不能用 @e 裸选择器 ★】marker 分散在坐标各处, 每条都带 distance=0.. 锁维度。
# ============================================================

# ① 找参与者: 与新区块"半径和"以内、就近 4 个(含自己)
tag @e[type=marker,tag=zx.db_field,distance=0..] remove zx.db_merge
execute as @e[type=marker,tag=zx.db_field,distance=0..10,sort=nearest,limit=4] run tag @s add zx.db_merge

# ② 数参与者
scoreboard players set #db_m zx.meta 0
execute as @e[tag=zx.db_merge,distance=0..] run scoreboard players add #db_m zx.meta 1

# ③ 只有自己一个 -> 不合并
execute if score #db_m zx.meta matches ..1 run tag @e[tag=zx.db_merge,distance=0..] remove zx.db_merge
execute if score #db_m zx.meta matches ..1 run return 0

# ④ 随机保留一个(领域中心 = 随机一个被合并的领域的中心; 文案原话)
tag @e[tag=zx.db_merge,distance=0..] remove zx.db_keep
execute as @e[tag=zx.db_merge,distance=0..,sort=random,limit=1] run tag @s add zx.db_keep

# ⑤ 先设: 半径按合并个数递增, 计时重置 6 秒
execute if score #db_m zx.meta matches 2.. as @e[tag=zx.db_keep,distance=0..,limit=1] run scoreboard players set @s zx.db_r 8
execute if score #db_m zx.meta matches 3.. as @e[tag=zx.db_keep,distance=0..,limit=1] run scoreboard players set @s zx.db_r 11
execute if score #db_m zx.meta matches 4.. as @e[tag=zx.db_keep,distance=0..,limit=1] run scoreboard players set @s zx.db_r 14
execute as @e[tag=zx.db_keep,distance=0..,limit=1] run scoreboard players set @s zx.db_ft 6

# ⑥ 后杀: 其余参与者收掉
execute as @e[tag=zx.db_merge,distance=0..] unless entity @s[tag=zx.db_keep] run kill @s

# ⑦ 表现: 合并那一刻的大水压
execute at @e[tag=zx.db_keep,distance=0..,limit=1] run particle minecraft:splash ~ ~0.5 ~ 3.5 0.6 3.5 0.12 40 normal
execute at @e[tag=zx.db_keep,distance=0..,limit=1] run particle minecraft:bubble ~ ~0.5 ~ 3.0 0.5 3.0 0.08 30 normal
execute at @e[tag=zx.db_keep,distance=0..,limit=1] run playsound minecraft:block.conduit.attack player @a ~ ~ ~ 1.0 0.7

# ⑧ 收尾
tag @e[tag=zx.db_merge,distance=0..] remove zx.db_merge
tag @e[tag=zx.db_keep,distance=0..] remove zx.db_keep
