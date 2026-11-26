# ============================================================
# fallendream:equipment/staff/polarized_light/cast —— 偏振光: 右键总入口(分派)
# ------------------------------------------------------------
# 【谁调用它】进度 fallendream:equipment/staff/polarized_light 的奖励
# 【操作方式】普通右键 = 普攻(attack) / 潜行 + 右键 = 主动技能(skill)
#   (谓词 fallendream:is_sneaking, 与风行于大地之上同一套)
# ============================================================

# ⓪ 撤销自己的进度(不然只有第一次右键会触发)
advancement revoke @s only fallendream:equipment/staff/polarized_light

# 分派: 潜行右键放技能, 普通右键打普攻
execute if predicate fallendream:is_sneaking run function fallendream:equipment/staff/polarized_light/skill
execute unless predicate fallendream:is_sneaking run function fallendream:equipment/staff/polarized_light/attack
