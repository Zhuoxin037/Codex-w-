# ============================================================
# sweetdream:equipment/armor/blaze_armor/pig_near_one —— 掐掉"挑不穿金甲的人"这条通道
# ------------------------------------------------------------
# 【执行者】16 格内的一只猪灵(由 pig_tick 第 ③ 步 as 过来)
# 【做什么】清 Brain 记忆 NEAREST_TARGETABLE_PLAYER_NOT_WEARING_GOLD。
#   这份记忆是"我附近有没有可以不穿金甲就打的人"的答案, 由 NearestPlayersSensor
#   每 20 刻刷一次 —— 穿了焱的人要的效果就是"永远答没有", 所以每刻清。
# 【★ 只掐这一条 ★】不去动 attack_target / angry_at:
#   那两条是"已经打起来了"的状态, 归 pig_calm 按 UUID 精确处理 ——
#   在这里不分青红皂白地清, 会把正在追别人 / 正在猎疣猪兽的猪灵也一起劝停。
# ============================================================

execute if data entity @s Brain.memories."minecraft:nearest_targetable_player_not_wearing_gold" run data remove entity @s Brain.memories."minecraft:nearest_targetable_player_not_wearing_gold"
