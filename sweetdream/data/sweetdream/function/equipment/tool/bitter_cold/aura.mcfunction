# ============================================================
# sweetdream:equipment/tool/bitter_cold/aura —— 苦寒: 常态缓慢Ⅱ
# ------------------------------------------------------------
# 【执行者】持「苦寒」的玩家(位置 = 自己)
# 【文案】自身 5 格内有「渊海」效果的生物获得常态的缓慢Ⅱ效果。
# 【"常态" = 每秒续】给 2 秒 —— 比 1 秒的续期周期略长, 保证不断档;
#   条件一旦消失就不再续, 最多 2 秒自然结束。别写成"一次性给 3 秒"。
# 【筛选条件的每一段】
#   tag=zx.status.yuanhai  只给带「渊海」的(文案限定)
#   distance=..5           5 格内; ★ 它同时兼任"锁维度"(裸 @e 会跨维度搜, 坑 55)
#   type=!#sweetdream:no_damage  排掉玩家/marker/掉落物/各类 display
#   nbt=!{Health:0.0f}     排掉"已死但还没消失"的尸体
# 【为什么用原版 effect】文案就是"缓慢Ⅱ"(amplifier 0-based: Ⅱ = 1), true = 不显示粒子,
#   与包内其它 debuff 的写法一致。
# ============================================================

effect give @e[type=!#sweetdream:no_damage,distance=..5,tag=zx.status.yuanhai,nbt=!{Health:0.0f}] minecraft:slowness 2 1 true
