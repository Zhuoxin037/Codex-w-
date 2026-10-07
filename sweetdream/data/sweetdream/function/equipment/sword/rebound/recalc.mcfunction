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
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/damage/calc
data modify storage zx:work rba.damage set from storage manacore:out r.damage
