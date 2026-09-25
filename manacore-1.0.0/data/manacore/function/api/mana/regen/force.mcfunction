# ============================================================
# api/mana/regen/force —— 特殊情况下的强制恢复
# ------------------------------------------------------------
# 【调用】data modify storage manacore:in arg set value {uuid:"<UUID>", value:25.0}
#          function manacore:api/mana/regen/force
# 【语义】无视恢复倍率、无视禁止恢复标记, 直接加 value 点(仍不超过上限)。
# 【典型场景】"战斗中也能生效"的瞬间回魔、剧情奖励、复活补蓝。
# ============================================================
data modify storage manacore:work a set value {uuid:"",value:0.0}
data modify storage manacore:work a merge from storage manacore:in arg
function manacore:api/player/ensure
execute if data storage manacore:work a.uuid run function manacore:internal/mana/force with storage manacore:work a
