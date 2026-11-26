# ============================================================
# fallendream:equipment/armor/lone_walk/hook_add —— 「独行」被动 +8%（加算池）
# ------------------------------------------------------------
# 【谁调用它】#manacore:event/damage_calc，排在 lib/dmg_add_apply **之前**
#   （加算池必须先填好，apply 才有东西可并）。
# 【执行者】施法者（玩家）
# 【★ 为什么不写在 hook_calc 里 ★】hook_calc 挂在 dmg_add_apply **之后**（独立乘区），
#   那时候加算池已经并进伤害了，再往里写不会有任何效果（静默失效）。
#   ★ 真实事故 2026-10-27: 曾经把 ① ② 都塞进 hook_calc（声明 `# @calc: add + indep`），
#     check.py 判"加算 hook 排在 apply 之后 = 永远不算"，两份增伤各自静默一半。
# 【★ 三次 dmg_add_put ★】它是宏（ch 一次只能一个通道），三条通道都 +8 = 整体 +8%，
#   属**非独立**（文案没写"独立乘区"）。
# ============================================================

execute unless entity @s[type=minecraft:player] run return 0
execute unless score @s zx.lw_on matches 1 run return 0

scoreboard players set #lw_8 zx.meta 8
data modify storage zx:work put set value {ch:"mm",pct:0}
execute store result storage zx:work put.pct int 1 run scoreboard players get #lw_8 zx.meta
function fallendream:lib/dmg_add_put with storage zx:work put

data modify storage zx:work put.ch set value "atk"
function fallendream:lib/dmg_add_put with storage zx:work put

data modify storage zx:work put.ch set value "oth"
function fallendream:lib/dmg_add_put with storage zx:work put
