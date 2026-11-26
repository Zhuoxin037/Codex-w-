execute if entity @s[tag=zx.s2_shield] run function fallendream:batch21/shield/external
# ============================================================
# fallendream:lib/thp/set —— 把「临时生命值」设成指定点数（本包唯一写吸收的地方）
# ------------------------------------------------------------
# 【入参】#thp_v zx.meta = 目标点数（整数，≥0；0 = 清空）
# 【执行者】玩家(@s)
# 【实现】原版没有"精确 N 点吸收"的接口，只有 `effect absorption <等级>`（每级 4 点）。
#   ⇒ 用两级拼：等级 = ceil(N/4)（吸收 4×等级），再用 `minecraft:max_absorption`
#      属性往下压 (4×等级 − N)，总上限正好落在 N 点（黄心数 = N/2）。
#      N=5 → 等级 2(8 点) + max_absorption −3 = 5 点。
# 【★ 这套独占 absorption 效果 ★】原版吸收只有一个值，本件与"法师预言·新生"那类
#   直接给 absorption 的效果**不能同时成立**（后写的一方会覆盖）。目前包内只有
#   profession/mage/p_rebirth 用它，两者同时触发的概率极低，暂按独占处理。
# 【★ 为什么先摘再挂 ★】同一 id 的 modifier 重复 add 会失败；摘不存在的会失败但
#   不截断后续命令，所以用标签 zx.thp_on 当"挂过"的判据。
# 【★ 时长 60 秒 / 到期由 lib/thp/tick 收 ★】不每秒刷新效果 —— absorption 效果
#   每 tick 会把吸收量重置到满级，每秒刷新等于"永远打不空"。所以给一次性长时长，
#   被打空 / 到期都由 tick 那边检测后 clear。
# ============================================================

# ① 目标点数落到玩家账本（负数/没分数一律按 0）
scoreboard players set @s zx.thp 0
execute if score #thp_v zx.meta matches 1.. run scoreboard players operation @s zx.thp = #thp_v zx.meta

# ② 摘掉上一轮的修饰符（挂过才摘）
execute if entity @s[tag=zx.thp_on] run attribute @s minecraft:max_absorption modifier remove fallendream:thp_cap
effect clear @s minecraft:absorption
tag @s remove zx.thp_on

# ③ 目标是 0 ⇒ 收工（连效果一起清）
execute if score @s zx.thp matches 0 run function fallendream:lib/thp/clear_soft
execute if score @s zx.thp matches 0 run return 0

# ④ 等级 = ceil(N/4) = (N+3)/4
scoreboard players operation #thp_lv zx.meta = #thp_v zx.meta
scoreboard players add #thp_lv zx.meta 3
scoreboard players operation #thp_lv zx.meta /= #4 zx.meta

# ⑤ 等级给的总吸收 = 4×等级；mod = N − 4×等级（≤0，作为 max_absorption 的增量）
scoreboard players operation #thp_all zx.meta = #thp_lv zx.meta
scoreboard players operation #thp_all zx.meta *= #4 zx.meta
scoreboard players operation #thp_mod zx.meta = #thp_v zx.meta
scoreboard players operation #thp_mod zx.meta -= #thp_all zx.meta

# ⑥ amplifier = 等级 − 1（原版从 0 起算）
scoreboard players remove #thp_lv zx.meta 1

# ⑦ 交给宏件（modifier 的数值与 effect 的等级都只能是字面量）
data modify storage zx:work thp set value {amp:0,mod:0}
execute store result storage zx:work thp.amp int 1 run scoreboard players get #thp_lv zx.meta
execute store result storage zx:work thp.mod int 1 run scoreboard players get #thp_mod zx.meta
function fallendream:lib/thp/apply with storage zx:work thp

# ⑧ 记到期刻（60 秒后；重置时刷新）
scoreboard players operation @s zx.thp_end = #now manacore.meta
scoreboard players add @s zx.thp_end 1200
