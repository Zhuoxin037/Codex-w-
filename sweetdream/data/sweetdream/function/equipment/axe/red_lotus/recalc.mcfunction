# ============================================================
# sweetdream:equipment/axe/red_lotus/recalc —— 算红莲两段伤害 + 记施法者 UUID
# ------------------------------------------------------------
# 【谁调用它】red_lotus/step_fire(要 dmg1) / step_night(要 dmg3) —— **每一段都重算一次**
# 【执行者】施法者本人(玩家)   ★ 2026-10-07 改: 以前调用它的是 cast 一次, 现在每段一次
# 【出参】zx:work rl = {dmg1: 基础攻击力×1, dmg3: 基础攻击力×3, u0..u3: 施法者 UUID}
# 【为什么存在独立节点 rl】两段伤害都要先在"施法者"身份下算出来, 再交给 hit_* 去打。
# 【★★ 为什么"每段都重算"而不是 cast 时算一次 ★★】
#   zx:work rl 是**共享节点**(全包很多函数会动 zx:work 下的东西), 而且"每 0.35 秒一段"
#   意味着那份值要**跨刻**活着 —— 两个玩家先后/同时施法就会互顶(一个人的伤害被另一个
#   覆盖, 甚至把 UUID 换掉 = 击杀记到别人头上)。所以改成每段当场算、当场用:
#   写 rl -> 同一次调用链里立刻被 hit_* 读走, 从不跨刻(和回锋 recalc 同一个理由)。
# 【两份都算的代价】每段会跑两次 api/damage/calc, 多出来的那一次只被丢掉 ——
#   相比"跨刻串味"的风险, 这点开销可以忽略(也省得再拆两个文件)。
# ============================================================

# 段1: 基础攻击力 ×1
data modify storage manacore:in arg set value {uuid:"",attack_mul:1.0,independent_multiplier:1.0,custom_damage:0.0,health_ratio:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/damage/calc
data modify storage zx:work rl.dmg1 set from storage manacore:out r.damage

# 段2: 基础攻击力 ×3
data modify storage manacore:in arg set value {uuid:"",attack_mul:3.0,independent_multiplier:1.0,custom_damage:0.0,health_ratio:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/damage/calc
data modify storage zx:work rl.dmg3 set from storage manacore:out r.damage

# 施法者 UUID 四整数(击杀归属)
data modify storage zx:work rl.u0 set from entity @s UUID[0]
data modify storage zx:work rl.u1 set from entity @s UUID[1]
data modify storage zx:work rl.u2 set from entity @s UUID[2]
data modify storage zx:work rl.u3 set from entity @s UUID[3]
