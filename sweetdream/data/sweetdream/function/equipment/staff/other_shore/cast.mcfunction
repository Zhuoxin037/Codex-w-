# ============================================================
# sweetdream:equipment/staff/other_shore/cast —— 彼岸 · 右键分派
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:equipment/staff/other_shore(consume_item) -> rewards
# 【分派】潜行右键 = 主动技能(skill) / 普通右键 = 普攻(attack)
# 【技能原文(必须和这里对上)】
#   ✦ 普攻   魔力 80 · 伤害 当前魔力值 ×0.02
#     "每次普攻命中后若其未附有「渊海」和「噬心」，则使其附加「渊海」。若其只附有
#      其中一种，则有 25% 的概率使其附加另一种。若其同时附有「渊海」和「噬心」，
#      则额外造成一次相当于自身最大魔力值 ×0.03 的真实伤害。附加效果对同一个生物
#      8 秒内最多触发一次。"
#   ✦ 主动技能   魔力 450 · 冷却 55 秒
#     "使用后选择自身 8 格内最多 3 个附有「渊海」或「噬心」的生物。若其只附有
#      「渊海」，则将其转化为「噬心」，并造成一次相当于自身最大魔力值 ×0.1 的伤害。
#      若其只附有「噬心」，则将其转化为「渊海」，并造成一次相当于自身最大魔力值
#      ×0.08 的真实伤害。若其同时附有两种效果，则消耗「渊海」和「噬心」，对其造成
#      一次相当于自身最大魔力值 ×0.2 的真实伤害，并对其 3 格内的其他生物造成一次
#      相当于自身最大魔力值 ×0.12 的伤害。每消耗一组「渊海」和「噬心」，则为自身
#      恢复最大生命值 5% 的生命。"
# 【前缀】zx.os_* / #os_* / zx:work os —— 定名前已全树 grep:
#   zx.os_ 与 zx:work os 在本包内没有占用(坑 167)。
# ============================================================

# ⓪ 撤销自己的进度(自撤销型进度首行必须 revoke)
advancement revoke @s only sweetdream:equipment/staff/other_shore

# ① 潜行 = 主动技能 / 不潜行 = 普攻
execute if predicate sweetdream:is_sneaking run function sweetdream:equipment/staff/other_shore/skill
execute unless predicate sweetdream:is_sneaking run function sweetdream:equipment/staff/other_shore/attack
