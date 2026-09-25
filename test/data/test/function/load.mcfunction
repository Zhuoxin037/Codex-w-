# ============================================================
# test:load —— 加载 / 重载时执行
# ------------------------------------------------------------
# 【谁调用它】data/minecraft/tags/function/load.json
# 【为什么用 execute unless + storage 标记来建计分板目标】
#   scoreboard objectives add 在目标已存在时会报错, 报错会中断整个函数 ——
#   第二次 /reload 之后后面的初始化就全都不跑了。
#   所以给目标配一个创建标记, 把 add 限制成一次。
#   (注意: scoreboard players set 在 1.21.5 不会自动建目标, 不能用它兜底。)
# 【test.meta 现在用来干嘛】记"备份架子连续丢了几 tick",
#   详见 internal/summon_named_stand。
# ============================================================

execute unless data storage test:config obj_meta run scoreboard objectives add test.meta dummy
execute unless data storage test:config obj_meta run data modify storage test:config obj_meta set value 1b
