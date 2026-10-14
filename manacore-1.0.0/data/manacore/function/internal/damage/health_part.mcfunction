# ------------------------------------------------------------
# internal/damage/health_part —— "最大生命 x 生命系数"这一项
# 【宏参数】manacore:work.a {uuid}; #hr = 生命系数 x100(calc 已读好)
# 【★ 双职责(D01 口径 B, 2026-10-11)★】除了累加进 #dmg(老路径), 还要累加进
#   #seg_x —— 生命项是"第四条分量", 与 custom_damage 合成 seg_x, 由 lib/dmg_add_apply
#   按分量级施加通道加成。**生命项不吃任何通道加算**(语义与 custom_damage 一致)。
# 【作用】#hp = max_health(x1000) × #hr(x100) ÷ 100, 同时 #dmg += #hp、#seg_x += #hp
# 【★★ A05(2026-10-11 三审): 不再裸乘 —— 走 mul_pct 的除余分解 ★★】
#   旧写法 `#hp *= #hr; /= #100` 先乘后除: 中间量 = 裸血×1000 × 系数×100 = 裸血×系数×1e5,
#   裸血×系数 只要超过约 21,474 就越 int32 回绕成负数, 随后被夹成 0。
#   报告例: max_health 1000 × health_ratio 30 ⇒ 1,000,000 × 3,000 = 3e9 → 回绕 → 0。
#   现在与 N10 同款: 交给 internal/damage/mul_pct 的"除余分解"(既不溢出也不掉精度)。
# 【API 输入支持范围 (★ Q06 2026-10-11 四审更正)】本项结果 = max_health(裸值) × health_ratio。
#   两条硬边界:
#     ① **结果 x1000 要装得下 int32** ⇒ max_health × health_ratio ≤ 2,147,483.647
#        (越过它不是"算不准", 而是定点运算的物理上限 —— 结果会回绕);
#     ② 倍率自身按 x100 进计分板 ⇒ health_ratio ≤ 约 2.1e7。
#   ★ 旧说明"只要乘积在 int32/1000 内就精确, 两者各自可达约 2.1e6"**不准**:
#     Q06 之前分解式的 ③ 步还有一条**与结果无关**的暗礁 99·倍率 ≤ int32
#     (即 health_ratio ≤ 约 217,000), 报告例 250000 正栽在那里 —— 结果明明装得下,
#     却因为"余数 99 乘以大倍率"而回绕(实得 456800.327, 真值 499750)。
#     该暗礁已由 mul_pct 的"对倍率二次分解"消掉(见 mul_pct 头部 Q06 段),
#     ⇒ 现在只剩上面那两条边界。
#   正常生存数值(血量 < 2 万、系数 < 10)离任一条都差几个数量级; 当前唯一非零调用 = 蛊毒 0.1。
# ------------------------------------------------------------
$execute store result score #hp manacore.math run data get storage manacore:players "$(uuid)".stats.max_health 1000
function manacore:internal/damage/mul_pct {src:"#hp",mul:"#hr",obj:"manacore.math"}
scoreboard players operation #hp manacore.math = #mul_out manacore.math
scoreboard players operation #dmg manacore.math += #hp manacore.math
scoreboard players operation #seg_x manacore.math += #hp manacore.math
