# ============================================================
# fallendream:equipment/staff/final_revelation/cast —— 终末天启: 右键总入口(分派)
# ------------------------------------------------------------
# 【谁调用它】进度 fallendream:equipment/staff/final_revelation 的奖励函数
# 【操作方式】普通右键 = 普攻(attack) / 潜行 + 右键 = 主动技能(skill)
#   (谓词 fallendream:is_sneaking, 与偏振光 / 风行于大地之上同一套)
# 【为什么只有这一处 revoke】三个入口(cast/attack/skill)共用同一个进度,
#   撤销必须发生在**进度刚被授予**的那一刻 —— 也就是这里。子函数不要再撤一次。
# ============================================================

# ⓪ 撤销自己的进度(不然只有第一次右键会触发)
advancement revoke @s only fallendream:equipment/staff/final_revelation

# 分派: 潜行右键放技能, 普通右键打普攻
execute if predicate fallendream:is_sneaking run function fallendream:equipment/staff/final_revelation/skill
execute unless predicate fallendream:is_sneaking run function fallendream:equipment/staff/final_revelation/attack
