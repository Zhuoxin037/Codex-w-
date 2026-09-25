# ============================================================
# api/mana/max/remove —— 削减最大魔力
# ------------------------------------------------------------
# 【调用】data modify storage manacore:in arg set value {uuid:"<UUID>", value:20.0}
#          function manacore:api/mana/max/remove
# 【副作用】如果当前魔力已经超过新上限, 会被一起夹取下来
#   (避免出现 "current_mana > max_mana" 的非法状态)。
# ============================================================
data modify storage manacore:work a set value {uuid:"",value:0.0}
data modify storage manacore:work a merge from storage manacore:in arg
function manacore:api/player/ensure
data modify storage manacore:work a.op set value "remove_max"
function manacore:internal/mana/apply with storage manacore:work a
