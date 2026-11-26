# ============================================================
# fallendream:equipment/axe/detach/ess_heal_go —— 兑现"同生体首次命中该生物 → 回 15%"
# ------------------------------------------------------------
# 【宏参数】zx:work detach {u:"<被打生物的 UUID>"}
# 【执行者】玩家（同生体）
# 【窗口判据】zx.dt_wend 是打在**被打生物**身上的秒级倒计时（detach/win_tick 每秒 -1，
#   归零就 reset）。用计分项而不是标签，是因为 `$(u)` 是裸 UUID：
#   `scoreboard players` 那一族吃 UUID，而 `@e[...]` 那一套选择器参数不能直接套在
#   UUID 后面（`$(u)[tag=...]` 不是合法选择器）。
# ★ 只兑现一次：兑现后立刻把倒计时 reset，并把玩家侧窗口清 0。
# ============================================================

$execute unless score $(u) zx.dt_wend matches 1.. run return 0

# 15% 最大生命（整点；0 点就只清窗口）
function fallendream:lib/max_health_score
scoreboard players operation #heal_pt zx.meta = #max_hp zx.meta
scoreboard players operation #heal_pt zx.meta /= #1000 zx.meta
scoreboard players operation #heal_pt zx.meta *= #15 zx.meta
scoreboard players operation #heal_pt zx.meta /= #100 zx.meta
execute if score #heal_pt zx.meta matches 1.. run function fallendream:lib/heal

$scoreboard players reset $(u) zx.dt_wend
scoreboard players set @s zx.dt_win 0

execute at @s run particle minecraft:heart ~ ~1.2 ~ 0.4 0.4 0.4 0.02 8 normal
execute at @s run playsound minecraft:entity.player.levelup player @a ~ ~ ~ 0.6 1.6
