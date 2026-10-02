# ============================================================
# sweetdream:equipment/armor/brain_leech/regen_add —— 挂上"每秒额外 +3 魔力"
# ------------------------------------------------------------
# 【为什么用前置包的恢复修正槽位】直接改面板的 mana_regen 会和别的东西抢
#   同一个数; 修正槽位是"各来源各占一格、最后求和"的, 摘得干净。
# 【id 固定】sweetdream:eqp_brain_leech —— 摘的时候按 id 精确移除。
# 【槽位】每人 8 格, 本件占 1 格。
# ============================================================

data modify storage manacore:in arg set value {uuid:"",id:"sweetdream:eqp_brain_leech",type:"equipment",value:3.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/mana/regen/modifier/add

scoreboard players set @s zx.bl_regen 1
