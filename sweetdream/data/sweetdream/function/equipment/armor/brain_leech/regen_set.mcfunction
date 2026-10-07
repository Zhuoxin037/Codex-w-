# ============================================================
# sweetdream:equipment/armor/brain_leech/regen_set —— 把回魔修正调成 #rv 那个值
# ------------------------------------------------------------
# 【入参】#rv = 0(没戴) / 3(普通) / 5(超限)   【执行者】玩家(zx:data self.uuid 已备好)
# 【为什么要"先摘再挂"】前置包的 modifier/add 不做同 id 去重 —— 直接再加一次
#   会白占一格; 而 remove 是按 id 精确删除(同 id 多条一次全删)。所以顺序固定:
#   有旧的先摘干净, 新值 > 0 再挂上, 最后把 zx.bl_rv 记成新值。
# 【幂等】#rv == zx.bl_rv 时调用方(brain_leech/passive)根本不会调进来。
# ============================================================

execute if score @s zx.bl_regen matches 1.. run function sweetdream:equipment/armor/brain_leech/regen_remove
execute if score #rv zx.meta matches 1.. run function sweetdream:equipment/armor/brain_leech/regen_add
scoreboard players operation @s zx.bl_rv = #rv zx.meta
