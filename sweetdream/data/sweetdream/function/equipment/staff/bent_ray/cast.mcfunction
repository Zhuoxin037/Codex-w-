# ============================================================
# sweetdream:equipment/staff/bent_ray/cast —— 折径 · 右键分派
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:equipment/staff/bent_ray(consume_item) -> rewards
# 【分派】潜行右键 = 主动技能(skill) / 普通右键 = 普攻(attack)
# 【技能原文(必须和这里对上)】
#   ✦ 普攻   魔力 60 · 伤害 8
#     "每次普攻命中后使其附加「折光」。"
#   ✦ 主动技能   魔力 250 · 冷却 30 秒
#     "使用后对自身 8 格内最近的生物发射光束，并对其造成一次相当于自身最大魔力值
#      ×0.04+8 的伤害。若其 5 格内有附有「折光」的生物，则光束继续射向其最近的附有
#      「折光」的生物并消除其「折光」，每次射出都会使本次伤害提高 20%（独立乘区，
#      不包含固定伤害）。以上最多重复 6 次。"
# 【★ 2026-10-17 用户拍板 ★】
#   ①「折光」持续 **10 秒**（原 15 秒；2026-10-23 用户拍板改为 10 秒，与整理稿
#      「折径·每层 10 秒」对齐。时长只在 mark_zg 里写一次 —— 改时长改那里）。
#   ② "最多重复 6 次" = **首段 + 6 次连锁**（最多 7 段），
#      第 n 段的独立乘区 = 1.2^n（n=0..6）。
# ============================================================

# ⓪ 撤销自己的进度
advancement revoke @s only sweetdream:equipment/staff/bent_ray

# ① 潜行 = 主动技能 / 不潜行 = 普攻
execute if predicate sweetdream:is_sneaking run function sweetdream:equipment/staff/bent_ray/skill
execute unless predicate sweetdream:is_sneaking run function sweetdream:equipment/staff/bent_ray/attack
