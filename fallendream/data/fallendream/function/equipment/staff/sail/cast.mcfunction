# ============================================================
# fallendream:equipment/staff/sail/cast —— 风帆: 右键总入口(分派)
# ------------------------------------------------------------
# 【谁调用它】进度 fallendream:equipment/staff/sail 的奖励(consume_item)
# 【操作方式】普通右键 = 普攻(attack) / 潜行 + 右键 = 主动技能(skill)
#   主动技能在"旋风正在进行"时会走**召回分支**(把被记录的生物拽到身边)。
# 【奖励函数第一行必须 revoke 自己】(check 规则 5 / 27 盯着)。
# ============================================================

advancement revoke @s only fallendream:equipment/staff/sail
execute if predicate fallendream:is_sneaking run function fallendream:equipment/staff/sail/skill
execute unless predicate fallendream:is_sneaking run function fallendream:equipment/staff/sail/attack
