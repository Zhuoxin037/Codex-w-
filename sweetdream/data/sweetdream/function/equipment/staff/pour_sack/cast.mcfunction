# ============================================================
# sweetdream:equipment/staff/pour_sack/cast —— 倾囊: 右键总入口(分派)
# ============================================================
advancement revoke @s only sweetdream:equipment/staff/pour_sack


execute if predicate sweetdream:is_sneaking run function sweetdream:equipment/staff/pour_sack/skill
execute unless predicate sweetdream:is_sneaking run function sweetdream:equipment/staff/pour_sack/attack
