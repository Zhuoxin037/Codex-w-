# ============================================================
# sweetdream:equipment/staff/twilight/tw_tick —— 一个暮光目标的每秒心跳
# ------------------------------------------------------------
# 【谁调用它】twilight/second(执行者 = 目标生物, at @s)
# 【技能原文(lore 逐字)】…且其抗性提升效果失效。持续 8 秒。
# 【抗性提升失效】每秒清一次(期间新获得的也清掉)。
# ============================================================

# ① 抗性提升失效
effect clear @s minecraft:resistance

# ② 表现(暗紫侵蚀)
particle minecraft:witch ~ ~1 ~ 0.4 0.6 0.4 0.02 8 normal
particle minecraft:smoke ~ ~0.8 ~ 0.3 0.4 0.3 0.02 4 normal

# ③ 倒计时; 到 0 摘掉修饰符
scoreboard players remove @s zx.tw_t 1
execute if score @s zx.tw_t matches ..0 run function sweetdream:equipment/staff/twilight/tw_end
