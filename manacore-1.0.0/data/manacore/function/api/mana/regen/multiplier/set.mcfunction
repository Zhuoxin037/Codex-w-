# ============================================================
# api/mana/regen/multiplier/set —— 设置恢复倍率
# ------------------------------------------------------------
# 【调用】data modify storage manacore:in arg set value {uuid:"<UUID>", value:1.5}
#          function manacore:api/mana/regen/multiplier/set
# 【语义】最终恢复量 = (基础 + 修正合计) x 倍率。
# 【用途】"冥想状态恢复速度 +50%"这类整体倍率。
# ============================================================
data modify storage manacore:work a set value {uuid:"",value:1.0}
data modify storage manacore:work a merge from storage manacore:in arg
function manacore:api/player/ensure
data modify storage manacore:work a.key set value "mana_regen_multiplier"
function manacore:internal/stats/set with storage manacore:work a
