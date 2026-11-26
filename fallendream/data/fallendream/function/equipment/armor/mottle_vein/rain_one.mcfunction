# ============================================================
# fallendream:equipment/armor/mottle_vein/rain_one —— 超限·杂纹: 给**这一只**随机附一个标签
# ------------------------------------------------------------
# 【执行者】@s = 那一批随机挑出来的生物之一（由 rain_tick 逐个 as 进来）
# 【五个标签等概率】lib/rnd 出 0..32767，%5 得 0..4：
#   0 渊海 / 1 流火 / 2 夜火 / 3 噬心 / 4 白昼梦
# 【★ 走 tag/mark ★】通用标签要带图标与计时，直接 tag add 只有判定没有表现，
#   而且不会衰减。target 写 "@s" 由宏展开成 `execute as @s`，就是本函数里这一只。
# 【★ 不复用 stellar_elegy/rnd_mark_one ★】那一个是"每只生物一辈子只吃一次"的
#   机制，会打 zx.star_rnd 去重；这里是每秒来一波、允许重复附, 不能打那个标。
# ============================================================

function fallendream:lib/rnd
scoreboard players operation #mv_r zx.meta = #rnd zx.meta
scoreboard players operation #mv_r zx.meta %= #5 zx.meta

execute if score #mv_r zx.meta matches 0 run data modify storage zx:work ic set value {target:"@s",mark:"yuanhai"}
execute if score #mv_r zx.meta matches 0 run function fallendream:tag/mark with storage zx:work ic
execute if score #mv_r zx.meta matches 1 run data modify storage zx:work ic set value {target:"@s",mark:"liuhuo"}
execute if score #mv_r zx.meta matches 1 run function fallendream:tag/mark with storage zx:work ic
execute if score #mv_r zx.meta matches 2 run data modify storage zx:work ic set value {target:"@s",mark:"yehuo"}
execute if score #mv_r zx.meta matches 2 run function fallendream:tag/mark with storage zx:work ic
execute if score #mv_r zx.meta matches 3 run data modify storage zx:work ic set value {target:"@s",mark:"shixin"}
execute if score #mv_r zx.meta matches 3 run function fallendream:tag/mark with storage zx:work ic
execute if score #mv_r zx.meta matches 4 run data modify storage zx:work ic set value {target:"@s",mark:"dream"}
execute if score #mv_r zx.meta matches 4 run function fallendream:tag/mark with storage zx:work ic
