# ============================================================
# sweetdream:lib/thp/add —— 在现有临时生命上"加 N 点"（带最大生命 ×2 的硬上限）
# ------------------------------------------------------------
# 【入参】#thp_v zx.meta = 增量（整数，≥0）
# 【执行者】玩家(@s)
# 【上限口径】「溢流」「蓄意」的文案都写了"最多有相当于自身最大生命值 ×2 的
#   临时生命值" ⇒ 这里统一夹到 最大生命×2（int 取整，和 lib/max_health_score 一致）。
#   ★ 本函数被 lib/heal（溢流）与蓄意每刻调用，属**热路径**，只做几次计分板运算。
# ============================================================

# ① 增量为 0 / 负数 ⇒ 什么都不做（只加不减；扣是 lib/thp/clear 的事）
execute if score #thp_v zx.meta matches ..0 run return 0

# ② 新值 = 旧值 + 增量
scoreboard players operation #thp_v zx.meta += @s zx.thp

# ③ 上限 = 最大生命 ×2（#max_hp 单位是 ×1000，先降到点）
function sweetdream:lib/max_health_score
scoreboard players set #2 zx.meta 2
scoreboard players set #thp_cap zx.meta 0
scoreboard players operation #thp_cap zx.meta = #max_hp zx.meta
scoreboard players operation #thp_cap zx.meta /= #1000 zx.meta
scoreboard players operation #thp_cap zx.meta *= #2 zx.meta
execute if score #thp_v zx.meta > #thp_cap zx.meta run scoreboard players operation #thp_v zx.meta = #thp_cap zx.meta

# ④ 真正落值
function sweetdream:lib/thp/set
