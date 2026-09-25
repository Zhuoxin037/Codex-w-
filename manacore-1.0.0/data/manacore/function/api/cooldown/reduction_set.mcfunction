# ============================================================
# api/cooldown/reduction_set —— 设置冷却缩减
# ------------------------------------------------------------
# 【调用】data modify storage manacore:in arg set value {uuid:"<UUID>", value:0.25}
#          function manacore:api/cooldown/reduction_set
# 【语义】0.25 = 所有吃缩减的技能冷却时间缩短 25%。
# 【取值】建议 0..1; 超过 1 会在计算时被夹到 1(即 0 冷却)。
# 【对谁生效】释放技能时 reduce:1b(默认) 的技能才会吃这个属性。
# ============================================================
data modify storage manacore:work a set value {uuid:"",value:0.0}
data modify storage manacore:work a merge from storage manacore:in arg
function manacore:api/player/ensure
data modify storage manacore:work a.key set value "cooldown_reduction"
function manacore:internal/stats/set with storage manacore:work a
