# ============================================================
# sweetdream:equipment/staff/fate_thread/cast —— 命缕 · 右键分派
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:equipment/staff/fate_thread(consume_item) -> rewards
# 【分派】潜行右键 = 主动技能(skill) / 普通右键 = 普攻(attack)
# 【技能原文(必须和这里对上)】
#   ✦ 普攻   魔力 80 · 伤害 1
#     "每次普攻命中后都会在其身上留下持续 5 秒的血色丝线。期间若普攻命中了其 5 格内的
#      另一个生物，则对二者分别造成一次相当于自身最大魔力值 ×0.05 的伤害，并使最初的
#      生物附加「噬心」，之后丝线消失。该效果 8 秒内不可再次触发。"
#   ✦ 主动技能   魔力 240 · 冷却 40 秒
#     "使用后选中自身 10 格内最近的一个附有「噬心」的生物，使其及 6 格内最多 2 个其他
#      生物以绯色丝线相连，持续 7 秒。期间其每次受到自身造成的伤害后，相连的其他生物
#      分别受到一次相当于本次伤害 ×0.3 的真实伤害（最多触发 6 次）。若其死亡或失去
#      「噬心」，则丝线断开；若与相连生物的距离超过 12 格，则对应丝线断开。"
# 【★ 两套"丝线"完全独立 ★】
#   · 普攻的血丝 = 生物身上的 zx.ft_ln + 到期刻 zx.ft_ln_end(5 秒)
#   · 主动的连丝 = 主目标 zx.ft_main / 相连者 zx.ft_lk + 同一个实例号 zx.ft_n,
#     状态全记在**玩家**身上(zx.ft_mine / ft_end / ft_got), 由 core/tick 每刻轮询
#     equipment/staff/fate_thread/watch。★ 不用 marker(2026-10-17 第二版)。
# ============================================================

# ⓪ 撤销自己的进度
advancement revoke @s only sweetdream:equipment/staff/fate_thread

# ① 潜行 = 主动技能 / 不潜行 = 普攻
execute if predicate sweetdream:is_sneaking run function sweetdream:equipment/staff/fate_thread/skill
execute unless predicate sweetdream:is_sneaking run function sweetdream:equipment/staff/fate_thread/attack
