# ============================================================
# sweetdream:equipment/sword/rebound/recalc —— 重算一次"基础攻击力 ×2", 存进 zx:work rba.damage
# ------------------------------------------------------------
# 【谁调用它】cast(第一次) / tick_step(每一次重复之前)
# 【执行者】施法者(玩家)
# 【为什么单独拆出来 ★】
#   "每 0.35 秒重复一次"意味着 cast 那一刻算好的伤害要**跨刻**复用 —— 而 zx:work rba
#   是**共享节点**, 两个玩家先后施法会互顶(一个人的伤害被另一个人的覆盖)。
#   所以改成"每次打击前当场重算": 写 zx:work rba -> 立刻 `with storage zx:work rba`
#   调 strike, 宏参数在调用那一瞬间取值, 不跨刻 -> 多人依次调用也不会串。
# ============================================================

function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0

data modify storage manacore:in arg set value {uuid:"",attack_mul:2.0}
# 超限档: 倍率 = **当前这一段**的千分比整数(zx.rb_omul) —— cast 起手 2000(×2),
#   tick_step 每段打之前 ×2 ⇒ 超限 4 层时各段 = ×2/×4/×8/×16/×32(2026-10-23 用户口径:
#   "每重复一次则当次伤害加倍率", 不是整轮统一 ×32)。这里 ×0.001 换回 double。
#   ★ 没这个分数(不该发生, cast 每次都会 set)时 store 失败 -> 保留上面的 2.0 保底。
execute store result storage manacore:in arg.attack_mul double 0.001 run scoreboard players get @s zx.rb_omul
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/damage/calc
data modify storage zx:work rba.damage set from storage manacore:out r.damage
