# ============================================================
# sweetdream:equipment/axe/azure_star/double —— 把"本次技能的最大魔力值倍率" ×2
# ------------------------------------------------------------
# 【谁调用它】azure_star/recalc(两段各自, 条件 = 身上攒着被动翻倍)
# 【执行者】施法者(玩家)
# 【改什么】只改 manacore:in arg.max_mana_mul(本武器两段都走这条通道)。
# 【怎么写】NBT 的 double 不能直接相乘 -> 走计分板定点: ×100 读出来, ×2, 再 ×0.01 写回。
# 【和「最大魔力值技能倍率」通用加成什么关系】完全独立: 那一份(风声 / 忘川彼岸 / 无效)
#   由 lib/mm_add/hook_calc 往**加算池的 mm 通道**写百分比(加算), 这里则是把本武器的
#   max_mana_mul **本身 ×2**。两者一个在加算池、一个在通道基值, 互不干扰
#   (旧版注释拿它和已删除的 lib/max_mana_bonus 比较, 那个函数 2026-10-07 已去掉)。
# 【★ 别在这里清 zx.as_x2 ★】清零在 recalc 开头一次做完(两段都要吃这一份翻倍)。
# ============================================================

scoreboard players set #as_d zx.meta 0
execute store result score #as_d zx.meta run data get storage manacore:in arg.max_mana_mul 100
scoreboard players operation #as_d zx.meta *= #2 zx.meta
execute store result storage manacore:in arg.max_mana_mul double 0.01 run scoreboard players get #as_d zx.meta
