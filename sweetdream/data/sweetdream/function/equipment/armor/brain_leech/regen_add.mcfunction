# ============================================================
# sweetdream:equipment/armor/brain_leech/regen_add —— 挂上"每秒额外 +N 魔力"
# ------------------------------------------------------------
# 【入参】#rv = 3(普通脑髓蛭) / 5(超限·脑髓蛭)   【执行者】玩家(zx:data self.uuid 已备好)
# 【谁调用它】brain_leech/regen_set —— 只在"想要的数值变了"时才进来。
# 【★ 为什么由 #rv 决定值, 而不是写死 3.0 ★】超限版把每秒回魔提到 5;
#   而"普通版 <-> 超限版"换头时 bl_regen 一直是 1, 不会经过"戴上"那个瞬间,
#   写死 3.0 就永远换不过挡。
# 【为什么用前置包的恢复修正槽位】直接改面板的 mana_regen 会和别的东西抢
#   同一个数; 修正槽位是"各来源各占一格、最后求和"的, 摘得干净。
# 【id 固定】sweetdream:eqp_brain_leech —— 摘的时候按 id 精确移除(同 id 多条一次全删)。
# 【槽位】每人 8 格, 本件占 1 格。
# ============================================================

data modify storage zx:work rv.val set value 3.0
execute if score #rv zx.meta matches 5.. run data modify storage zx:work rv.val set value 5.0

data modify storage manacore:in arg set value {uuid:"",id:"sweetdream:eqp_brain_leech",type:"equipment",value:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
data modify storage manacore:in arg.value set from storage zx:work rv.val
function manacore:api/mana/regen/modifier/add

scoreboard players set @s zx.bl_regen 1
