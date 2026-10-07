# ============================================================
# sweetdream:equipment/sword/myriad/ju_enter —— 进入 3 秒「居合」
# ------------------------------------------------------------
# 【执行者】玩家
# 【文案】若自身有 5 个“剑魂”且被动或主动使用了该技能则进入 3 秒「居合」状态。
# 【★ 只在剑魂满 5 时才进 ★】判据在调用方(ju_check), 本函数只负责"进"。
# 【★ 时长是"拉满"不是"加层" ★】重复触发只会把 zx.mq_ju 刷回 3, 不会叠成 6。
#   文案说"进入 3 秒「居合」状态", 是重新计时不是延长(延长是另一条规则,
#   见 ju_extend —— 那是"每切换一次延长一秒")。
# ============================================================

scoreboard players set @s zx.mq_ju 3
execute at @s run particle minecraft:flash ~ ~1.2 ~ 0 0 0 0.0 1 normal
execute at @s run particle minecraft:dust{color:[1.0,0.92,0.72],scale:1.4} ~ ~1 ~ 1.2 0.8 1.2 0.03 30 normal
execute at @s run playsound minecraft:item.trident.thunder player @a ~ ~ ~ 0.7 1.9
tellraw @s [{"text":"「居合」","color":"gold","bold":true},{"text":" —— 3 秒","color":"yellow"}]
