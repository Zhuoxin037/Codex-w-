# ============================================================
# sweetdream:upgrade/api/ms_tick —— 魔力沸涌: 攒够 every 秒就减 1 秒冷却
# ------------------------------------------------------------
# 【入参】zx:work cq {uuid, skill}; @s zx.msp_c = 已攒秒数
# 【执行者】玩家本人
# 【判据已由 cd_tick 判完】到这里就说明"魔力确实低于阈值", 只管攒秒。
# 【为什么要攒秒而不是每秒减】文案是"每 3 秒 -1 秒"(α/β) —— 也就是平均
#   每秒 -1/3 秒; 攒满一次减 1 秒是同一件事, 而且不会出现"每秒减 0.33 秒"
#   这种没法表达的数。
# ============================================================

scoreboard players add @s zx.msp_c 1

scoreboard players set #ev zx.meta 0
execute store result score #ev zx.meta run data get storage zx:out r.ms_every
# every 读不到 / 是 0 时兜底成 1(否则下面永远不成立, 这个效果就静默失效)
execute if score #ev zx.meta matches ..0 run scoreboard players set #ev zx.meta 1

execute if score @s zx.msp_c >= #ev zx.meta run function sweetdream:upgrade/api/cd_reduce1
execute if score @s zx.msp_c >= #ev zx.meta run scoreboard players set @s zx.msp_c 0
