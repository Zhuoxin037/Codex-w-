# ============================================================
# api/mana/regen/ban —— 禁止魔力恢复
# ------------------------------------------------------------
# 【调用模板】
#   限时: data modify storage manacore:in arg set value {uuid:"<UUID>", seconds:5.0}
#   永久: data modify storage manacore:in arg set value {uuid:"<UUID>", ticks:0}
#   function manacore:api/mana/regen/ban
# 【说明】ticks 优先; ticks<=0 时用 seconds; 两者都 <=0 -> 永久禁止。
# 【影响范围】只拦"自动恢复"。api/mana/add 与 api/mana/regen/force 仍然有效。
# 【解除】api/mana/regen/unban。
# ============================================================
data modify storage manacore:work a set value {uuid:"",ticks:0,seconds:0.0}
data modify storage manacore:work a merge from storage manacore:in arg
function manacore:api/player/ensure
execute if data storage manacore:work a.uuid run function manacore:internal/mana/ban with storage manacore:work a
