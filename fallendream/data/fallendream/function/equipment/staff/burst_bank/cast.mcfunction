# ============================================================
# fallendream:equipment/staff/burst_bank/cast —— 决堤: 右键总入口(分派)
# ============================================================
advancement revoke @s only fallendream:equipment/staff/burst_bank


execute if predicate fallendream:is_sneaking run function fallendream:equipment/staff/burst_bank/skill
execute unless predicate fallendream:is_sneaking run function fallendream:equipment/staff/burst_bank/attack
