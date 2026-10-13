# ============================================================
# sweetdream:equipment/staff/triad/cast —— 很冰的斧: 右键总入口(分派)
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:equipment/staff/triad 的奖励
# 【操作方式】普通右键 = 普攻(attack) / 潜行 + 右键 = 主动技能(skill)
#   —— 与其余法杖完全一致, 不另发明操作方式。
# ★ 本武器是**三形态**：形态切换、强化时长都只在主动技能里发生；
#   普攻永远打"当前形态"那一套(伤害公式 + 被动), 见 attack / ball_hit。
# ============================================================

# ⓪ 撤销自己的进度(不然只有第一次右键会触发)
advancement revoke @s only sweetdream:equipment/staff/triad

# 分派: 潜行右键放技能, 普通右键打普攻
execute if predicate sweetdream:is_sneaking run function sweetdream:equipment/staff/triad/skill
execute unless predicate sweetdream:is_sneaking run function sweetdream:equipment/staff/triad/attack
