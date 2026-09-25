# ============================================================
# api/stats/set —— 写入某项属性(不存在则自动创建)
# ------------------------------------------------------------
# 【调用模板】
#   data modify storage manacore:in arg set value {uuid:"<UUID>", key:"base_attack", value:20.0}
#   function manacore:api/stats/set
# 【说明】value 是完整 NBT 值, 字符串/列表也能写(不只是数字)。
# 【典型用途】装备系统换装后重算面板。
# 【注意】写 current_mana / max_mana 时不会自动夹取; 需要夹取请用
#   api/mana/set 与 api/mana/max/set, 这里追求"精确写入"。
# ============================================================
data modify storage manacore:work a set value {uuid:"",key:"",value:0.0}
data modify storage manacore:work a merge from storage manacore:in arg
function manacore:api/player/ensure
function manacore:internal/stats/set with storage manacore:work a
