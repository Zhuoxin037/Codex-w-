# ============================================================
# sweetdream:equipment/staff/renew_fire/cast —— 续火 · 右键分派
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:equipment/staff/renew_fire(consume_item) -> rewards
# 【分派】潜行右键 = 主动技能(skill) / 普通右键 = 普攻(attack)
# 【技能原文(必须和这里对上)】
#   ✦ 普攻   魔力 20 · 伤害 5
#     "每次普攻命中后累计一次，每累计 3 次则恢复自身 1 点生命值。切换武器后清空次数。"
#   ✦ 主动技能   魔力 50 · 冷却 30 秒
#     "使用后恢复自身 8 点生命值。自身生命值为满时无法使用。"
# 【★ 累计次数记在玩家身上(zx.rf_n) ★】不记在生物/球上 —— 它是"自己的连续命中",
#   换目标不重置; 只有"切换武器"才清零(lib/second 每秒查主手, 见 tick1s 的说明)。
# ============================================================

# ⓪ 撤销自己的进度
advancement revoke @s only sweetdream:equipment/staff/renew_fire

# ① 潜行 = 主动技能 / 不潜行 = 普攻
execute if predicate sweetdream:is_sneaking run function sweetdream:equipment/staff/renew_fire/skill
execute unless predicate sweetdream:is_sneaking run function sweetdream:equipment/staff/renew_fire/attack
