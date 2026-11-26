# ============================================================
# fallendream:equipment/staff/begonia/cast —— 海棠: 右键总入口(分派)
# ------------------------------------------------------------
# 【谁调用它】进度 fallendream:equipment/staff/begonia 的奖励(consume_item)
# 【操作方式】普通右键 = 普攻(attack) / 潜行 + 右键 = 主动技能(skill)
# 【怎么区分】谓词 fallendream:is_sneaking。
# 【奖励函数第一行必须 revoke 自己】(check 规则 5 / 27 盯着)。
# ============================================================

advancement revoke @s only fallendream:equipment/staff/begonia
execute if predicate fallendream:is_sneaking run function fallendream:equipment/staff/begonia/skill
execute unless predicate fallendream:is_sneaking run function fallendream:equipment/staff/begonia/attack
