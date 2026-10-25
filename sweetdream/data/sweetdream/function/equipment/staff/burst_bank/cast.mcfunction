# ============================================================
# sweetdream:equipment/staff/burst_bank/cast —— 决堤: 右键总入口(分派)
# ============================================================
advancement revoke @s only sweetdream:equipment/staff/burst_bank


execute if predicate sweetdream:is_sneaking run function sweetdream:equipment/staff/burst_bank/skill
execute unless predicate sweetdream:is_sneaking run function sweetdream:equipment/staff/burst_bank/attack
