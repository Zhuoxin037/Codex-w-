# ============================================================
# sweetdream:equipment/staff/wind_ontheground/cast —— 右键总入口(分派)
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:equipment/staff/wind_ontheground 的奖励
# 【这个武器的操作方式】
#   普通右键   = 普攻(attack)
#   潜行 + 右键 = 主动技能(skill)
# 【怎么区分】用谓词 sweetdream:is_sneaking(minecraft:entity_properties
#   + flags.is_sneaking)。它判断的是"触发这一下的时候你在不在潜行"。
#   —— 这样两个动作共用同一次右键消耗, 不用做两套物品。
# ============================================================

# ⓪ 撤销自己的进度(不然只有第一次右键会触发)
advancement revoke @s only sweetdream:equipment/staff/wind_ontheground

# 分派: 潜行右键放技能, 普通右键打普攻
execute if predicate sweetdream:is_sneaking run function sweetdream:equipment/staff/wind_ontheground/skill
execute unless predicate sweetdream:is_sneaking run function sweetdream:equipment/staff/wind_ontheground/attack
