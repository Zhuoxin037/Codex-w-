# ============================================================
# api/mana/consume —— 魔力消耗(带"够不够"判定)
# ------------------------------------------------------------
# 【调用模板】
#   data modify storage manacore:in arg set value {uuid:"<UUID>", value:20.0}
#   function manacore:api/mana/consume
#   /execute if data storage manacore:out r {success:1b} run <继续你的技能>
# 【出参】out.success = 1b 已扣除 / 0b 魔力不足(一个字节都没扣)
#         out.reason  = "ok" / "mana"
# 【为什么要用这个而不是 remove】它能保证"要么完整扣款, 要么完全不扣",
#   避免技能失败却已经扣了蓝。
# ============================================================
# 出参: manacore:out.success (1=魔力足够并已扣除, 0=不足)
data modify storage manacore:work a set value {uuid:"",value:0.0}
data modify storage manacore:work a merge from storage manacore:in arg
function manacore:api/player/ensure
function manacore:internal/mana/consume with storage manacore:work a
