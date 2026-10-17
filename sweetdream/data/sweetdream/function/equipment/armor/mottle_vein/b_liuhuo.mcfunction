# ============================================================
# sweetdream:equipment/armor/mottle_vein/b_liuhuo —— 杂纹: 本轮消费过「流火」
# ------------------------------------------------------------
# 【谁调用它】reward ③   【执行者】玩家
# 【技能原文】"若消耗了「流火」则额外恢复 30 点魔力值。"
# 【★ 与基础那 20 点是两笔 ★】文案是"额外" ⇒ 一共 50(20 + 30), 不是"改成 30"。
# ============================================================

function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0
data modify storage manacore:in arg set value {uuid:"",value:30.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/mana/add
