# ============================================================
# sweetdream:equipment/bow/arc/ol_calc —— 超限·电弧: 起放电时把伤害算成快照
# ------------------------------------------------------------
# 【谁调用它】arc/ol_begin 第 ② 步(execute as <射手> at @s)
# 【出参】zx:work aw{d2: <伤害 double>, u0..u3: 射手 UUID 四个整数}
# 【口径】与原版 damage_go 完全一致: attack_mul:2.0(基数 = 面板 base_attack)
#   + other_mul:0.03(基数默认 = 当前魔力)。两条通道都写, 没写的 max_mana_mul 当 0。
# 【为什么在这里算】超限版放电持续 3 秒, 这 3 秒里拿不到射手(人会走位/会死) —— 照
#   崩裂·裂缝(fissure/field)那套"施放那刻算好、锚点存着用"的口径。
# ============================================================

data modify storage manacore:in arg set value {uuid:"",attack_mul:2.0,other_mul:0.03}
function manacore:api/player/self_uuid
data modify storage manacore:in arg.uuid set from storage manacore:out r.uuid
function manacore:api/damage/calc

data modify storage zx:work aw.d2 set from storage manacore:out r.damage
data modify storage zx:work aw.u0 set from entity @s UUID[0]
data modify storage zx:work aw.u1 set from entity @s UUID[1]
data modify storage zx:work aw.u2 set from entity @s UUID[2]
data modify storage zx:work aw.u3 set from entity @s UUID[3]
