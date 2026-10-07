# ============================================================
# sweetdream:equipment/axe/chenyuan/slow_check —— 这只生物带不带「缓慢」
# ------------------------------------------------------------
# 【执行者】刚被打中的那只生物
# 【产出】#cy_slow zx.meta = 1(带缓慢) / 0(不带)
# 【★ 三层判定, 而且写在独立的小函数里 ★】
#   ① 1.20.5 起实体 NBT 的 active_effects(蛇形命名)
#   ② 旧拼写 ActiveEffects 兜底
#   ③ 谓词 sweetdream:has_slowness 再兜一层
#   为什么放独立函数: 万一谓词加载失败, `if predicate` 那行报错只会中断**这个小函数**,
#   不会把外层的"冷却 -1 秒"一起带走(#cy_slow 在前面两行就已经有值了)。
# ============================================================

scoreboard players set #cy_slow zx.meta 0
execute if data entity @s {active_effects:[{id:"minecraft:slowness"}]} run scoreboard players set #cy_slow zx.meta 1
execute if score #cy_slow zx.meta matches 0 if data entity @s {ActiveEffects:[{Id:"minecraft:slowness"}]} run scoreboard players set #cy_slow zx.meta 1
execute if score #cy_slow zx.meta matches 0 if predicate sweetdream:has_slowness run scoreboard players set #cy_slow zx.meta 1
