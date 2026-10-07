# ============================================================
# sweetdream:equipment/axe/fissure/recalc —— 算崩裂两段伤害(写进 zx:work fia)
# ------------------------------------------------------------
# 【谁调用它】fissure/cast(⑥ 之前)
# 【出参】zx:work fia = {damage: 立即段(基础攻击力×5), dmg2: 每秒段(基础攻击力×1)}
# 【为什么两段分开算】两段倍率不同; 且裂缝开出来之后每秒都要用同一个"释放者基础攻击力"
#   -> 结算那一刻算好、写进 marker 的 NBT(见 field/field_tick)。
# 【通道】都是 attack_mul(基础攻击力倍率); 基数由框架取面板 base_attack。
# ============================================================

# 立即段: 基础攻击力 ×5
data modify storage manacore:in arg set value {uuid:"",attack_mul:5.0,independent_multiplier:1.0,custom_damage:0.0,health_ratio:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/damage/calc
data modify storage zx:work fia.damage set from storage manacore:out r.damage

# 每秒段: 基础攻击力 ×1
data modify storage manacore:in arg set value {uuid:"",attack_mul:1.0,independent_multiplier:1.0,custom_damage:0.0,health_ratio:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/damage/calc
data modify storage zx:work fia.dmg2 set from storage manacore:out r.damage
