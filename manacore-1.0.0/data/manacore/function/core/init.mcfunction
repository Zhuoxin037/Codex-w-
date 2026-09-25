# ============================================================
# core/init —— 创建计分板目标(可反复调用)
# ------------------------------------------------------------
# 【为什么必须用它】`scoreboard players set` **不会**自动创建目标 ——
#   目标不存在时会直接报 "Unknown scoreboard objective" 并中断函数。
#   所以计分板目标只能用 `scoreboard objectives add` 创建。
# 【为什么要有标记保护】`scoreboard objectives add` 在目标已存在时会报错,
#   而报错会中断整个函数(第二次 /reload 之后就会全停)。所以每个目标
#   配一个"已创建"标记, 把创建动作限制成一次性操作。
# 【幂等】标记存在时只会做 4 次存在性判断, 开销可忽略, 可以每秒调用。
# ============================================================
execute unless data storage manacore:config obj_meta run scoreboard objectives add manacore.meta dummy
execute unless data storage manacore:config obj_meta run data modify storage manacore:config obj_meta set value 1b
execute unless data storage manacore:config obj_math run scoreboard objectives add manacore.math dummy
execute unless data storage manacore:config obj_math run data modify storage manacore:config obj_math set value 1b
execute unless data storage manacore:config obj_timer run scoreboard objectives add manacore.timer dummy
execute unless data storage manacore:config obj_timer run data modify storage manacore:config obj_timer set value 1b
execute unless data storage manacore:config obj_slot run scoreboard objectives add manacore.slot dummy
execute unless data storage manacore:config obj_slot run data modify storage manacore:config obj_slot set value 1b
execute unless data storage manacore:config obj_beat run scoreboard objectives add manacore.beat dummy
execute unless data storage manacore:config obj_beat run data modify storage manacore:config obj_beat set value 1b
data modify storage manacore:config inited set value 1b
