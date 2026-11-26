# ============================================================
# fallendream:equipment/staff/pour_sack/cast —— 倾囊: 右键总入口(分派)
# ============================================================
advancement revoke @s only fallendream:equipment/staff/pour_sack


execute if predicate fallendream:is_sneaking run function fallendream:equipment/staff/pour_sack/skill
execute unless predicate fallendream:is_sneaking run function fallendream:equipment/staff/pour_sack/attack
