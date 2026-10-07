# ============================================================
# api/damage/calc —— 只算伤害, 不打出去
# ------------------------------------------------------------
# 【调用模板】
#   data modify storage manacore:in arg set value {uuid:"<UUID>", attack_mul:2.0,
#       independent_multiplier:1.5, custom_damage:10.0}
#   function manacore:api/damage/calc
#   /data get storage manacore:out r.damage
# 【字段】
#   max_mana_mul           : 最大魔力值技能倍率(基数 = 玩家最大魔力)
#   attack_mul             : 基础攻击力倍率(基数 = base_attack, -1 = 玩家面板攻击力)
#   other_mul              : 其他倍率(基数 = other_base, -1 = 玩家当前魔力)
#   base_attack            : -1(默认) = 用面板 base_attack; 也可直接给数值
#   other_base             : -1(默认) = 用面板 current_mana; 也可直接给数值
#   independent_multiplier : 独立乘区
#   custom_damage          : 技能固定伤害
#   health_ratio           : 可选, 最大生命 x 该比例也计入
#   (旧名 skill_multiplier 仍认, 等同 attack_mul)
# 【★ 三条通道只写你要的那条 ★】没写的通道当 0; 三条都不写才退回"攻击力 x1"。
#   例如"最大魔力结算"的技能只写 max_mana_mul:0.08, 不会再叠加一份面板攻击力。
# 【公式】(最大魔力xmax_mana_mul + 攻击力xattack_mul + 其他基数xother_mul
#          + 固定伤害 + 最大生命x生命系数) x 独立乘区
# 【出参】out.damage
# 【用途】用于做伤害预览、数值平衡表、或者你自己接手后续的伤害结算。
# ============================================================
data modify storage manacore:work a set value {uuid:"",base_attack:-1.0,other_base:-1.0,independent_multiplier:1.0,custom_damage:0.0,health_ratio:0.0}
data modify storage manacore:work a merge from storage manacore:in arg
function manacore:api/player/ensure
execute if data storage manacore:work a.uuid run function manacore:internal/damage/calc with storage manacore:work a
