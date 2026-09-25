# ============================================================
# api/damage/calc —— 只算伤害, 不打出去
# ------------------------------------------------------------
# 【调用模板】
#   data modify storage manacore:in arg set value {uuid:"<UUID>", skill_multiplier:2.0,
#       independent_multiplier:1.5, custom_damage:10.0}
#   function manacore:api/damage/calc
#   /data get storage manacore:out r.damage
# 【字段】
#   base_attack            : -1(默认) = 用玩家面板的 base_attack; 也可直接给数值
#   skill_multiplier       : 技能倍率
#   independent_multiplier : 独立乘区
#   custom_damage          : 技能固定伤害
#   health_ratio           : 可选, 最大生命 x 该比例也计入
# 【公式】(base_attack x 技能倍率 + 固定伤害 + 最大生命x生命系数) x 独立乘区
# 【出参】out.damage
# 【用途】用于做伤害预览、数值平衡表、或者你自己接手后续的伤害结算。
# ============================================================
# 出参: manacore:out.damage
# 公式: (基础攻击力 x 技能倍率 + 技能固定伤害 + 最大生命 x 生命系数) x 独立乘区
data modify storage manacore:work a set value {uuid:"",base_attack:-1.0,skill_multiplier:1.0,independent_multiplier:1.0,custom_damage:0.0,health_ratio:0.0}
data modify storage manacore:work a merge from storage manacore:in arg
function manacore:api/player/ensure
execute if data storage manacore:work a.uuid run function manacore:internal/damage/calc with storage manacore:work a
