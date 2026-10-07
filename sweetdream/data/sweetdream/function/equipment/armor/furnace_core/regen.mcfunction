# ============================================================
# sweetdream:equipment/armor/furnace_core/regen —— 燃灰的每秒回魔
# ------------------------------------------------------------
# 【执行者】玩家   【谁调用它】passive 的第 ⑧ 步(层数 >= 1 时才调)
# 【回多少】#ash 里是层数, 每层 1 点 —— 由调用方保证 #ash 已经是"参与计算的层数"
#   (脱下装备时是 0, 那时根本不会走到这里)。
# 【为什么用 api/mana/add 而不是 regen modifier】前置包的 regen 是"每秒恢复速率",
#   而这里是"到点直接加一笔"。直接 add 才能精确等于层数, 也不会被回魔倍率放大。
#   (加到上限由 api/mana/add 内部夹紧, 不会溢出。)
# 【为什么不在这里累加 zx.regen_extra】那本账是给 debug 面板"回魔/秒"看的,
#   由 passive 统一累加 —— 那边加了, 这里再加就翻倍了。
# ============================================================

data modify storage manacore:in arg set value {uuid:"",value:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute store result storage manacore:in arg.value double 1 run scoreboard players get #ash zx.meta
function manacore:api/mana/add
