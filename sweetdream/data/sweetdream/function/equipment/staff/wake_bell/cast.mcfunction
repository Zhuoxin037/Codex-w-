# ============================================================
# sweetdream:equipment/staff/wake_bell/cast —— 醒梦钟 · 右键分派
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:equipment/staff/wake_bell(consume_item) -> rewards
# 【分派】潜行右键 = 主动技能(skill) / 普通右键 = 普攻(attack)
#   与同批所有法杖一致(begonia / long_night / late_court)。
# 【技能原文(必须和这里对上)】
#   ✦ 普攻   魔力 60 · 伤害 最大魔力值 ×0.02
#     "每次普攻命中后若其附有「白昼梦」，则额外造成一次相当于自身最大魔力值 ×0.02 的伤害。"
#   ✦ 主动技能   魔力 400 · 冷却 70 秒
#     "使用后消耗自身 8 格内最多 3 个生物的「白昼梦」，并对其造成一次相当于自身最大
#      魔力值 ×0.1 的真实伤害。"
# ============================================================

# ⓪ 撤销自己的进度(自撤销型进度首行必须 revoke)
advancement revoke @s only sweetdream:equipment/staff/wake_bell

# ① 潜行 = 主动技能 / 不潜行 = 普攻
execute if predicate sweetdream:is_sneaking run function sweetdream:equipment/staff/wake_bell/skill
execute unless predicate sweetdream:is_sneaking run function sweetdream:equipment/staff/wake_bell/attack
