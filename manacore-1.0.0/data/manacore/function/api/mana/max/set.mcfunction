# ============================================================
# api/mana/max/set —— 设置最大魔力
# ------------------------------------------------------------
# 【调用】data modify storage manacore:in arg set value {uuid:"<UUID>", value:200.0}
#          function manacore:api/mana/max/set
# 【注意】调高上限后当前魔力不会自动补满, 需要再调 api/mana/add。
#   调低上限时, 当前魔力会在下一次写入时被夹回上限(也可用 mana/set 立即修)。
# ============================================================
data modify storage manacore:work a set value {uuid:"",value:100.0}
data modify storage manacore:work a merge from storage manacore:in arg
function manacore:api/player/ensure
data modify storage manacore:work a.key set value "max_mana"
function manacore:internal/stats/set with storage manacore:work a
