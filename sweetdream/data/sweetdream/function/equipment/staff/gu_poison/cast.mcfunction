# ============================================================
# sweetdream:equipment/staff/gu_poison/cast —— 蛊毒: 右键总入口(分派)
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:equipment/staff/gu_poison 的奖励(consume_item)
# 【操作方式】普通右键 = 普攻(attack) / 潜行 + 右键 = 主动技能(skill)
# 【奖励函数第一行必须 revoke 自己】(check 规则 5 / 27 盯着)。
# ============================================================

advancement revoke @s only sweetdream:equipment/staff/gu_poison
execute if predicate sweetdream:is_sneaking run function sweetdream:equipment/staff/gu_poison/skill
execute unless predicate sweetdream:is_sneaking run function sweetdream:equipment/staff/gu_poison/attack
