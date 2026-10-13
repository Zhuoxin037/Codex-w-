# ============================================================
# sweetdream:equipment/staff/five_curses/cast —— 五世恶咒: 右键总入口(分派)
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:equipment/staff/five_curses 的奖励
# 【操作方式】普通右键 = 普攻(attack) / 潜行 + 右键 = 主动技能(skill)
#   与堕梦 / 其余法杖同一套手感, 不另发明操作方式。
# ============================================================

# ⓪ 撤销自己的进度(不然只有第一次右键会触发)
advancement revoke @s only sweetdream:equipment/staff/five_curses

# 分派: 潜行右键放技能, 普通右键打普攻
execute if predicate sweetdream:is_sneaking run function sweetdream:equipment/staff/five_curses/skill
execute unless predicate sweetdream:is_sneaking run function sweetdream:equipment/staff/five_curses/attack
