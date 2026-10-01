# ============================================================
# sweetdream:lib/timestop —— 把一批生物"时停"指定 tick 数(NoAI 完全定格)
# ------------------------------------------------------------
# 【宏参数】zx:work fz {target, ticks}
# 【和 lib/freeze 的区别】冷冻 = 原版 TicksFrozen + 速度归零(还能转身/攻击);
#   时停 = NoAI(完全定格)。两者**各用各的计时**:
#     冷冻 -> zx.fz_end      时停 -> zx.ts_end
#   以前共用 zx.fz_end, 谁后放谁把对方的时长冲掉(建议清单第 4 条)。
# 【★ 保存原状态 ★】NoAI 是覆盖式的: 如果这只生物本来就 NoAI:1b,
#   解冻时必须还原成 1b, 不能一律写成 0b(否则会放开本来禁止 AI 的生物)。
#   所以先把它原本是不是 NoAI 记进 zx.noai_bak, 解冻时照原样还原。
# ============================================================

$execute as $(target) run scoreboard players operation @s zx.ts_end = #now manacore.meta
$execute as $(target) run scoreboard players add @s zx.ts_end $(ticks)
$execute as $(target) run scoreboard players set @s zx.noai_bak 0
$execute as $(target) if data entity @s {NoAI:1b} run scoreboard players set @s zx.noai_bak 1
$execute as $(target) run data modify entity @s NoAI set value 1b
$execute as $(target) run tag @s add zx.stop