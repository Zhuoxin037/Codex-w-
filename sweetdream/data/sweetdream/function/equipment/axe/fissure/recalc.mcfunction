# ============================================================
# sweetdream:equipment/axe/fissure/recalc —— 算崩裂两段伤害 + 裂缝时长(写进 zx:work fia)
# ------------------------------------------------------------
# 【谁调用它】fissure/cast(⑤; is_ol 判完之后)
# 【出参】zx:work fia = {damage: 立即段, dmg2: 每秒段, ft: 裂缝持续秒数}
# 【为什么两段分开算】两段倍率不同; 且裂缝开出来之后每秒都要用同一个"释放者基础攻击力"
#   -> 结算那一刻算好、写进实体 NBT(见 field/field_tick)。
# 【通道】都是 attack_mul(基础攻击力倍率); 基数由框架取面板 base_attack。
# 【超限分档(读 zx:work fia.ol, 由 cast 从 is_ol 拍进来)】
#   立即段 ×5 -> ×6; 裂缝时长 5 秒 -> 8 秒; 每秒段 ×1 **不变**;
#   前方格数与采样球数在 dmg 里分档, 裂缝半径(3 格)不变。
# ============================================================

# 立即段: 基础攻击力 ×5(原版) / ×6(超限)
data modify storage manacore:in arg set value {uuid:"",attack_mul:5.0,independent_multiplier:1.0,custom_damage:0.0,health_ratio:0.0}
execute if data storage zx:work fia{ol:1} run data modify storage manacore:in arg.attack_mul set value 6.0
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/damage/calc
data modify storage zx:work fia.damage set from storage manacore:out r.damage

# 每秒段: 基础攻击力 ×1(两版相同)
data modify storage manacore:in arg set value {uuid:"",attack_mul:1.0,independent_multiplier:1.0,custom_damage:0.0,health_ratio:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/damage/calc
data modify storage zx:work fia.dmg2 set from storage manacore:out r.damage

# 裂缝持续秒数: 5(原版) / 8(超限)
data modify storage zx:work fia.ft set value 5
execute if data storage zx:work fia{ol:1} run data modify storage zx:work fia.ft set value 8
