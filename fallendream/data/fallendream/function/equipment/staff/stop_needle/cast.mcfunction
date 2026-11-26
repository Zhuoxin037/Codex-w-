# ============================================================
# fallendream:equipment/staff/stop_needle/cast —— 停针: 右键总入口(分派)
# ------------------------------------------------------------
# 【操作方式】普通右键 = 普攻(attack) / 潜行 + 右键 = 主动技能(skill)
# 【怎么区分】谓词 fallendream:is_sneaking（22 件法杖统一范式）。
# ============================================================
advancement revoke @s only fallendream:equipment/staff/stop_needle


execute if predicate fallendream:is_sneaking run function fallendream:equipment/staff/stop_needle/skill
execute unless predicate fallendream:is_sneaking run function fallendream:equipment/staff/stop_needle/attack
