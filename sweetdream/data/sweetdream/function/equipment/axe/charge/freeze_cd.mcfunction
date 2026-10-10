# ============================================================
# sweetdream:equipment/axe/charge/freeze_cd —— 超限·超•负•荷: 冻结本技能冷却(1 秒)
# ------------------------------------------------------------
# 【原文】"该技能停止正常冷却缩减"
# 【谁调用它】tick(超载状态每秒, 且**已进第二形态** chg_mode=1 才调 —— 见 tick ③)
# 【执行者】玩家
# 【口径(用户 2026-10-10 定稿)】冻结**只在第二形态的超载状态期间** —— 状态一结束立刻恢复
#   自然冷却(所以打完一轮"回归正常"后冷却会继续走, 见 end_ol 头部)。
#   ★ 第一阶段(**第一形态**, chg_mode=0 的那段 15 秒)的状态**不冻**, 冷却照常自然 -1/秒
#     (2026-10-10 用户纠正: "在第一阶段是不冻结的, 超载阶段才会冻结")。
#   状态期间它就只能靠"攻击到生物 -4 秒"那个被动往下减(见 hit)。
# 【为什么这样写】manacore 的冷却是"记结束时刻 end"式的
#   (players.<uuid>.cooldowns.<skill>.end = 绝对游戏刻), **没有全局衰减器** ——
#   "自然减少"其实就是 #now 在涨 ⇒ **冻结 = 每秒把 end 后推 20 刻**。
#   (借 manacore:api/cooldown/increase 实现, 它的语义是"加冷却", 这里当作"抵消流逝"。)
# 【★★ 顺序: 必须先查、后冻 ★★】
#   先冻(+20)会把"刚到点的冷却"又推远 ⇒ 状态结束后永远等不到"就绪" ⇒ 自动使用静默死循环。
#   且只在"冷却中"才冻: 已就绪时 check 已把过期记录惰性清掉, 再 increase 会把刚好的冷却推远。
#   (check.py 规则 78 `cdstop` 盯的就是这个形状。)
# ============================================================

# ① 拿 uuid
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# ② 先查(只读; 顺带把已过期的记录惰性清掉)
#   ★ 判据必须写成**带花括号的路径** `r{ready:1b}` —— 写成 SNBT 键值对会整份函数不加载。
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:charge"}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/cooldown/check

# ③ 冷却中 -> 把结束时刻后推 20 刻(抵消这一秒的自然流逝)
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:charge",ticks:20}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute unless data storage manacore:out r{ready:1b} run function manacore:api/cooldown/increase
