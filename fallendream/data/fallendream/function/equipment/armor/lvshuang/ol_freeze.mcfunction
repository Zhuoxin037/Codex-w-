# ============================================================
# fallendream:equipment/armor/lvshuang/ol_freeze —— 超限·冰冻踩上来的生物（执行者 = 霜片）
# ------------------------------------------------------------
# 【谁调用它】frost_tick ①.5（每秒一次，只对超限档的霜）
# 【原文】"生物踩到霜时…会被冰冻 1 秒。…每增加一层则生物踩到霜后冷冻的时间 +1 秒。"
# 【时长】20 + 20×档 刻（档 0 = 1 秒，档 3 = 4 秒）。走 lib/freeze：原版 TicksFrozen
#   结霜外观 + 移动速度归零（还能转身、还能出招，与时停是两套）。到点它自己解。
# 【★ 节流 = "踩到"只算一次 ★】
#   每只生物身上记 zx.lsh_fz = 上次被霜冻的绝对刻；本次要满足
#     #now - zx.lsh_fz >= 本次冻结时长 + 20 刻
#   才再冻一次。不节流的话：站在霜上 → 每秒被重冻 → 走不动 → 离不开霜 → 永久锁死。
#   节流之后是"冻一段、放一段"，它有机会走出 1.2 格。
# 【★ 已经冻着的直接跳过 ★】别的来源的冷冻（永霜/冷凝壳/冷鸦）正在生效时不要去
#   抢它的 zx.fz_end，也不要刷新自己的节流时间戳。
# 【★ zx.lsh_fzr 是什么 ★】本轮筛出来的"该冻"的那一批，批量交给 lib/freeze 一次。
# ============================================================

# ① 本次冻结时长 = 20 + 20 × 档
scoreboard players set #lsh_20 zx.meta 20
scoreboard players operation #lsh_add zx.meta = @s zx.lsh_lv
scoreboard players operation #lsh_add zx.meta *= #lsh_20 zx.meta
scoreboard players set #lsh_tick zx.meta 20
scoreboard players operation #lsh_tick zx.meta += #lsh_add zx.meta

# ② 节流阈值 = 时长 + 20（给"放出来"的那一段留出能走开的窗口）
scoreboard players operation #lsh_need zx.meta = #lsh_tick zx.meta
scoreboard players add #lsh_need zx.meta 20

# ③ 逐个筛
tag @e[type=!#fallendream:no_damage,distance=..1.2] remove zx.lsh_fzr
execute as @e[type=!#fallendream:no_damage,distance=..1.2] run function fallendream:equipment/armor/lvshuang/freeze_one
execute unless entity @e[tag=zx.lsh_fzr,distance=..16] run return 0

# ④ 批量冻（lib/freeze 的 target 可以直接给范围选择器，内部 execute as 逐个处理）
data modify storage zx:work fz set value {target:"@e[tag=zx.lsh_fzr,distance=..16]",ticks:20}
execute store result storage zx:work fz.ticks int 1 run scoreboard players get #lsh_tick zx.meta
function fallendream:lib/freeze with storage zx:work fz

# ⑤ 表现
execute at @e[tag=zx.lsh_fzr,distance=..16] run particle minecraft:item_snowball ~ ~0.6 ~ 0.3 0.4 0.3 0 10 normal
execute at @e[tag=zx.lsh_fzr,distance=..16] run playsound minecraft:block.powder_snow.break player @a ~ ~ ~ 0.6 1.2
tag @e[tag=zx.lsh_fzr,distance=..16] remove zx.lsh_fzr
