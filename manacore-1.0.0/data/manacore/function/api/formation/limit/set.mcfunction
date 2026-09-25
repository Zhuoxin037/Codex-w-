# ============================================================
# api/formation/limit/set —— 修改术阵数量上限
# ------------------------------------------------------------
# 【调用】data modify storage manacore:in arg set value {uuid:"<UUID>", value:5}
#          function manacore:api/formation/limit/set
# 【这是"未来可更改术阵数量的道具"的接入点】上限没有被写死在框架里,
#   它存在每个玩家的 stats.formation_limit 上, 所有判断都读这个属性。
#   所以道具只要在获得/失去时调用本接口即可, 无需改动任何判断逻辑。
# 【注意】上限调低时已存在的术阵不会被自动删除, 只是之后不能再新建。
# ============================================================
data modify storage manacore:work a set value {uuid:"",value:3}
data modify storage manacore:work a merge from storage manacore:in arg
function manacore:api/player/ensure
data modify storage manacore:work a.key set value "formation_limit"
function manacore:internal/stats/set with storage manacore:work a
