# ============================================================
# sweetdream:equipment/staff/thunderrod/cast —— 引雷针: 右键总入口(分派)
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:equipment/staff/thunderrod 的奖励
# 【操作方式】普通右键 = 普攻(attack) / 潜行 + 右键 = 主动技能(skill)
#   (与其余 13 把法杖同一套分派, 见 staff/delusion/cast)
# ============================================================

advancement revoke @s only sweetdream:equipment/staff/thunderrod

execute if predicate sweetdream:is_sneaking run function sweetdream:equipment/staff/thunderrod/skill
execute unless predicate sweetdream:is_sneaking run function sweetdream:equipment/staff/thunderrod/attack
