# ============================================================
# sweetdream:equipment/armor/profile/heal —— 剖面: 自身恢复 10% 生命值
# ------------------------------------------------------------
# 【执行者】玩家（穿剖面的那个人）
# 【文案】"…且自身恢复 10% 生命值。"
# 【×1000 定点】lib/max_health_score 出参 #max_hp = 最大生命 ×1000;
#   10% = #max_hp ÷ 10 ÷ 1000（两次整点除法, 只会少不会多）。
# 【为什么走 lib/heal】它是"精确恢复 N 点"的唯一正解（玩家 NBT 写不了,
#   instant_health 只有 4·2^k 档位）—— 见 lib/heal 文件头。
# ============================================================

function sweetdream:lib/max_health_score
scoreboard players set #heal_pt zx.meta 0
scoreboard players operation #heal_pt zx.meta = #max_hp zx.meta
scoreboard players operation #heal_pt zx.meta /= #10 zx.meta
scoreboard players operation #heal_pt zx.meta /= #1000 zx.meta
execute if score #heal_pt zx.meta matches 1.. run function sweetdream:lib/heal
