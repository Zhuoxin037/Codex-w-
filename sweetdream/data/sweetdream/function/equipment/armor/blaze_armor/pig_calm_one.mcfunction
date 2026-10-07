# ============================================================
# sweetdream:equipment/armor/blaze_armor/pig_calm_one —— 焱·单只猪灵"劝和"
# ------------------------------------------------------------
# 【执行者】那只正对玩家发怒的猪灵(由 pig_calm 精确匹配后送进来)
# 【★ 为什么每个 remove 都先 if data ★】键不存在时 data remove 会失败
#   (命令返回 0), 在事件链里会变成"这一条没执行成功"的噪音; 先判一次干净。
# ============================================================

execute if data entity @s AngryAt run data remove entity @s AngryAt
execute if data entity @s Brain.memories."minecraft:angry_at" run data remove entity @s Brain.memories."minecraft:angry_at"
# 已经在朝我挥拳的那份"当前目标"也要摘掉, 不然手上这一下还是会落下来。
#   ★ 只在这里(AngryAt 已经确认 == 我)摘, 不去误伤追别人的猪灵 —— 见 pig_near_one。
execute if data entity @s Brain.memories."minecraft:attack_target" run data remove entity @s Brain.memories."minecraft:attack_target"
