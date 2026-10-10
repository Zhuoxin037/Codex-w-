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
# manacore.gen —— ★ F01 修(2026-10-10): "注册代"。core/boot 每次加载时 +1,
#   玩家 @s 上记"我是第几代注册的"; tick_self 靠它判"本代是否已注册"。
#   用它替代原来"拿 #sec 当注册标记"的写法(那一版每秒都会判成"需要注册")。
execute unless data storage manacore:config obj_gen run scoreboard objectives add manacore.gen dummy
execute unless data storage manacore:config obj_gen run data modify storage manacore:config obj_gen set value 1b
# manacore.u0..u3 —— ★ O02(2026-10-11, spark 剖析): 玩家自己的 UUID 四个 int 的
#   **每玩家缓存**(internal/uuid/collect_self 写一次, session/tick_self 每秒读)。
#   原来每秒 4 次 `data get entity @s UUID[n]` = 4 次全玩家 NBT 序列化; UUID 终身
#   不变, 缓存后每秒只剩计分板读。存在性判定不能建 0 分(UUID int 可能恰好是 0/负),
#   见 collect_self 头注释。
execute unless data storage manacore:config obj_u0 run scoreboard objectives add manacore.u0 dummy
execute unless data storage manacore:config obj_u0 run data modify storage manacore:config obj_u0 set value 1b
execute unless data storage manacore:config obj_u1 run scoreboard objectives add manacore.u1 dummy
execute unless data storage manacore:config obj_u1 run data modify storage manacore:config obj_u1 set value 1b
execute unless data storage manacore:config obj_u2 run scoreboard objectives add manacore.u2 dummy
execute unless data storage manacore:config obj_u2 run data modify storage manacore:config obj_u2 set value 1b
execute unless data storage manacore:config obj_u3 run scoreboard objectives add manacore.u3 dummy
execute unless data storage manacore:config obj_u3 run data modify storage manacore:config obj_u3 set value 1b
data modify storage manacore:config inited set value 1b
