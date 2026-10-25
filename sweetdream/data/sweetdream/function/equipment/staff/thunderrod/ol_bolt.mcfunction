# ============================================================
# sweetdream:equipment/staff/thunderrod/ol_bolt —— 超限·引雷针: 闪电的「+最大魔力 ×0.1」附伤
# ------------------------------------------------------------
# 【谁调用它】bolt_skill 第 ③ 步(`if score @s zx.tr_ol matches 1`)
# 【执行者】主人(玩家), 位置 = 雷的落点
# 【文案】"且本次闪电伤害**额外附加**相当于自身最大魔力值 ×0.1 的伤害。"
#   ★ "附加" = 在原版闪电那 5 点之外**再加一刀**, 不是把闪电伤害改掉(那 5 点没有
#     归属、也不走本包通道, 改不动)。所以这里是独立的一次 max_mana_mul 结算。
#   ★ 每道雷各结算一次: 超限是"每只目标三道雷" ⇒ 一只挨三道就吃三次附伤, 这是
#     文案"各降下三道闪电 + 本次闪电伤害额外附加"的自然读法。
# ============================================================

# ① 算伤害 = 最大魔力 ×0.1
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0
data modify storage manacore:in arg set value {uuid:"",max_mana_mul:0.1,independent_multiplier:1.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/damage/calc

# ② 打给落点 3 格内的全部生物(与文案"本次闪电"笼罩的范围一致)
data modify storage zx:work a set value {target:"@e[type=!#sweetdream:no_damage,distance=..3]",damage:0.0,type:"minecraft:player_attack"}
execute if data storage zx:config damage_type run data modify storage zx:work a.type set from storage zx:config damage_type
data modify storage zx:work a.damage set from storage manacore:out r.damage
data modify storage zx:work a.num set from storage manacore:out r.damage
function sweetdream:lib/num/plain
function sweetdream:internal/damage/with_from with storage zx:work a

# ③ 表现
particle minecraft:electric_spark ~ ~1.2 ~ 0.4 0.6 0.4 0.04 16 normal
