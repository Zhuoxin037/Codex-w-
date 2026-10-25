# ============================================================
# sweetdream:lib/hp_pct —— 生命百分比（×100）公共原语
# ------------------------------------------------------------
# 【执行者】任意有生命值的实体(@s)
# 【出参】#hp_p100 zx.meta = 生命百分比 ×100（满血 = 10000, 50% = 5000）
# 【★ 为什么不用 data get entity Health ★】
#   那是**整份玩家 NBT 序列化**（≈10 ms/次, 卡顿坑 1 的头号来源）。
#   本包已经在 core/load 注册了 criterion 记分板 `zx.hp_c`
#   （`scoreboard objectives add zx.hp_c health`）—— 原版每刻自动同步,
#   读它就是一次纯计分板操作, 完全免费。
# 【换算】hp 点数 × 1000 × 100 ÷ 最大生命毫点 = 百分比 ×100
#   例: 20 点血 / 20 点上限 ⇒ 20×1000×100 = 2,000,000 ÷ 20,000 = 100
#   ★ 乘法顺序不能反: 先 ×1000 再 ×100（上限 1024 血时约 1.02e8, 离 2^31 还很远）。
# 【★ 分母用 lib/max_health_score ★】它会把 lib/heal 临时压上限的 modifier 加回去,
#   否则"正在被治疗的那一拍"算出来的百分比会偏高。
# ============================================================

function sweetdream:lib/max_health_score
scoreboard players set #hp_p100 zx.meta 0
scoreboard players operation #hp_p100 zx.meta = @s zx.hp_c
scoreboard players operation #hp_p100 zx.meta *= #1000 zx.meta
scoreboard players operation #hp_p100 zx.meta *= #100 zx.meta
execute if score #max_hp zx.meta matches 1.. run scoreboard players operation #hp_p100 zx.meta /= #max_hp zx.meta
