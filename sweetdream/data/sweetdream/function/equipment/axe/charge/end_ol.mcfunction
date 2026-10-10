# ============================================================
# sweetdream:equipment/axe/charge/end_ol —— 超限·超•负•荷: 15 秒状态结束后的分支
# ------------------------------------------------------------
# 【谁调用它】end(状态倒计时归零时, 仅当这次施法是超限版)
# 【原文】"该状态结束后若该技能完成冷却，则自动使用且该技能停止正常冷却缩减…"
# 【执行者】玩家
# 【两种情况(2026-10-10 用户定稿)】
#   ① 状态结束这一拍冷却**已经归零** -> 进第二形态(首次)+ 立刻自动使用一次
#      (重新起 100 秒冷却 + 新状态), 继续超载;
#      · 第一形态: 冷却**没被冻**(照常自然 -1/秒 —— 15 秒白减 15 秒) + 平A的 -4 秒被动;
#      · 第二形态: 状态期间冷却**被冻住**(见 tick ③ -> freeze_cd), 只能靠 -4 秒被动压到 0。
#   ② 冷却还没归零 -> 什么都不做。超载就此结束, 冷却从下一秒起**恢复自然减少**
#      (冻结只在**第二形态**的状态期间, 见 tick ③); **不再有"冷却走完自动使用"**
#      —— 要再放得自己手动按(2026-10-10 删掉 mode_tick 那条路)。
#   ★ 这里**不再**用 chg_mode 早退: 第二形态的人同样要吃到"状态结束即放"的即时性。
# ============================================================

# ① 拿 uuid
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# ② 冷却完成了吗
#   ★ 判据必须是**带花括号的路径** `r{ready:1b}`(出参在 manacore:out.r.ready)。
#     写成 `data storage manacore:out ready:1b`(把 SNBT 键值对当路径)不是"判错",
#     而是 `ready:1b` 不是合法 NBT 路径 ⇒ **整个函数加载失败**(零日志)。
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:charge"}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/cooldown/check
execute unless data storage manacore:out r{ready:1b} run return 0

# ③ 进第二形态(拿加成) + 立刻自动使用一次
function sweetdream:equipment/axe/charge/mode_on
function sweetdream:equipment/axe/charge/autocast
