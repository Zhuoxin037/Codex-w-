# ============================================================
# api/mana/max/add —— 增加最大魔力
# ------------------------------------------------------------
# 【调用】data modify storage manacore:in arg set value {uuid:"<UUID>", value:50.0}
#          function manacore:api/mana/max/add
# 【用途】等级成长、装备加成。脱下时用 value 传负数即可。
# ============================================================
data modify storage manacore:work a set value {uuid:"",value:0.0}
data modify storage manacore:work a merge from storage manacore:in arg
function manacore:api/player/ensure
data modify storage manacore:work a.key set value "max_mana"
function manacore:internal/stats/add with storage manacore:work a
