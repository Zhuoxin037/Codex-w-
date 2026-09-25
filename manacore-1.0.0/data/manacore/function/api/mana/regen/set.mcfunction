# ============================================================
# api/mana/regen/set —— 设置每秒基础恢复
# ------------------------------------------------------------
# 【调用】data modify storage manacore:in arg set value {uuid:"<UUID>", value:1.0}
#          function manacore:api/mana/regen/set
# 【说明】这就是"每秒恢复 X 点魔力"里的 X, 新玩家默认 1.0。
# 【注意】它只是"基础值"; 装备/被动请用 regen/modifier/add 追加修正。
# ============================================================
data modify storage manacore:work a set value {uuid:"",value:1.0}
data modify storage manacore:work a merge from storage manacore:in arg
function manacore:api/player/ensure
data modify storage manacore:work a.key set value "mana_regen"
function manacore:internal/stats/set with storage manacore:work a
