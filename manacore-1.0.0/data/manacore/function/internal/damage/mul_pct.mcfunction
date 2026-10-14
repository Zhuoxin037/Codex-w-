# ============================================================
# internal/damage/mul_pct —— 定点乘法"除余分解"(宏)
# ------------------------------------------------------------
# 【宏参数】{src, mul, obj} —— 三个**名字**(写成字符串)
#   src = 被乘的定点数(x1000) 的**持有者名**(如 "#base_m")
#   mul = 倍率(x100; 1.0->100) 的**持有者名**(如 "#mul_m")
#   obj = ★ 上面两个持有者所在的 **objective 名**(如 "manacore.math" / "zx.meta")
#     ★★ A01(2026-10-11 三审)修: 原来 objective **硬编码** manacore.math ——
#        而调用方 sweetdream:lib/dmg_add_apply 的分数全写在 zx.meta, 于是
#        "持有者名对、objective 错" ⇒ 输入一律读不到(0) ⇒ 只要本轮有增伤,
#        重算结果就是 0(报告例: 该给 115, 实得 0)。现在 objective 由调用方
#        **显式传入**; 本文件不再出现任何硬编码的输入 objective。
#   ★ 三个参数一个都不能缺: 缺 $(obj) 的行取不到变量 ⇒ 整个宏函数**运行时作废**
#     (宏缺失变量是运行期错误, 不进 latest.log)。check.py 有接线锁守着调用方。
# 【出参】#mul_out($(obj), x1000) = src × mul ÷ 100(向下取整)
#   ★ 只写 #mul_out, **不动 src / mul**, 所以调用方可以 src == dst 地自乘。
# 【谁调用它】
#   · manacore:internal/damage/calc        传 obj:"manacore.math"
#   · manacore:internal/damage/health_part 传 obj:"manacore.math"
#   · sweetdream:lib/dmg_add_apply         传 obj:"zx.meta"
# ------------------------------------------------------------
# 【★★ N10(2026-10-11): 为什么不能直接 `src *= mul; /= #100` ★★】
#   计分板是 32 位有符号整数(上限 2,147,483,647)。原写法先乘后除, 中间量是
#   src×mul = (裸值×1000)×(倍率×100) = 裸值×倍率×100000 ⇒ 裸值 × 倍率 只要超过
#   **约 21,474** 就回绕成负数, 随后 calc 末尾的 `matches ..0 -> 0` 把它夹成 0:
#     报告例: max_mana 30,000 × 1.0 ⇒ 30,000,000×100 = 3,000,000,000 → -1,294,967,296 → 0
#     玩家看到的是"面板 3 万的最大魔力技打出 0 伤害"。
#   ★ 也不能"先 ÷100 再 ×倍率": 那会把 45.67 砍成 45.6, **常态**掉两位精度。
#   ★ 也不能"往 int32 上界钳": 会把 30,000 压成 21,474 —— 对**合法输入**给出错误结果。
# 【正解 = 除余分解】把 B 拆成"整百部分 + 余数":
#       B = 100·q + r        (q = B ÷ 100, r = B − 100·q, |r| < 100)
#   于是 B×M÷100 = q·M + r·M÷100
#     · 前半 q·M 的量级**就是最终结果本身**(x1000) —— 只要结果装得下 int32 就绝不溢出;
#     · 后半 r·M ≤ 99·|M| —— 量级小, 但**并非"恒安全"**: |M| 一大(> 约 2.17e7)照样
#       回绕, 而且这条界**与最终结果无关**(Q06 已对它再做一次分解, 见下);
#     · 两项相加 = **精确值**(与单步 B×M÷100 逐位一致)。
# 【★ 除法语义(三审 V01 更正, 2026-10-11)★】计分板的 `/=` **不是**向零截断, 而是
#   MathHelper.floorDiv —— 即 **向下取整**(往 −∞ 走): -1/100 的分数结果是 -1(不是 0)。
#   本文件旧注释把 `/=` 说成"向零截断"是**错的**, 已改。
#   ★ 但分解式在 floorDiv 下**依然精确**: q 与 r 都用同一个 `/=`(同一舍入方向),
#     r 又恒落在 (−100,100), 于是 q·M + r·M÷100 与单步 floor(B×M÷100) 逐位相同。
#   已用 **floor** 语义重跑 20 万组随机(B 取满 int32、M 含负数) —— 0 例不符
#   (.workbuddy/_sim_mulpct.py)。
# 【★★ Q06(2026-10-11 四审): ③ 步对倍率再做一次分解 ★★】
#   上面的分解把 "B" 拆开了, 但 ③ 步算的是 r·M÷100 —— 而 |r| ≤ 99 ⇒ 它的中间量
#   99·|M| **与最终结果无关**: 只要 |M| > 约 2.17e7 就回绕, 哪怕结果完全装得下。
#   报告例: max_health=1.999 / health_ratio=250000 ⇒ B=1999, M=25,000,000:
#     q = 19 ⇒ 前半 19×25,000,000 = 475,000,000 ✓(结果量级, 本来就没问题)
#     r = 99 ⇒ 后半 99×25,000,000 = 2,475,000,000 → 回绕 -1,819,967,296
#     ⇒ 旧出参 456,800,327(x1000 = 456800.327), 真值 499,750。
#   修法 = 对 M **再做一次同款除余分解**(与 B 那次逐字同构):
#       M = 100·q1 + r2   (q1 = M÷100, r2 = M − 100·q1 ∈ [0,100))
#     ⇒ r·M÷100 = r·q1 + r·r2÷100
#         · 前半 r·q1 ≤ |M|         (只要倍率自身装得下 int32 就安全)
#         · 后半 r·r2 ≤ 99×99 = 9801 (恒安全)
#   ⇒ 修完之后本文件的实质上限只剩两条: **结果装得下 int32**(① 步 q·M —— 定点运算的
#     物理边界)与 **|M| ≤ int32**(输入自身装得下)。20 万+ 组 floor 语义复验见
#     .workbuddy/_sim_mulpct.py ⑤ 节(旧式 456800327 → 新式 499750000 = 真值)。
#   ★ 为什么选"继续分解"而不是"给 API 加强制范围校验"(报告给的二选一): 分解是
#     **纯代数恒等**, 零行为风险; 而加校验要改 api/damage/calc 的成败语义, 波及所有
#     技能, 而且会拦掉本来完全正确的输入。
# 【★ 为什么余数用减法而不是 `%=` ★】原版 `%=` 对**负数**取余到底跟不跟 Java 的
#   截断规则, 本项目没有先例背书(现有 `%=` 全是非负场景)。用 `r = B − (B÷100)·100`
#   只依赖 `/=`(已实测 = floorDiv, 规则 69/74 盯着的那个), 对正负号严格成立。
# 【为什么有的行没有 `$`】没出现 $(变量) 的行**不能**加 `$` —— 规则 dollar:
#   带 `$` 却没宏变量 = 整个函数作废。本文件每行都含 $(obj) 或 $(src)/$(mul), 故都带 `$`。
# ============================================================

# ① q = src ÷ 100; 后半先算 q·M(量级 = 最终结果)
$scoreboard players operation #q $(obj) = $(src) $(obj)
$scoreboard players operation #q $(obj) /= #100 manacore.meta
$scoreboard players operation #q $(obj) *= $(mul) $(obj)

# ② r = src − (src÷100)×100   ← 不用 %= 的原因见文件头
$scoreboard players operation #r $(obj) = $(src) $(obj)
$scoreboard players operation #r $(obj) /= #100 manacore.meta
$scoreboard players operation #r $(obj) *= #100 manacore.meta
$scoreboard players operation #lo $(obj) = $(src) $(obj)
$scoreboard players operation #lo $(obj) -= #r $(obj)

# ③ 后半 r·M÷100
#   ★ Q06(四审): 旧式 `#lo *= $(mul); #lo /= #100` 的中间量 99·|M| 与结果无关,
#     |M| > 约 2.17e7 就回绕 ⇒ 这里**再分解一次倍率**(见文件头 Q06 段):
#       M = 100·q1 + r2  ⇒  r·M÷100 = r·q1 + r·r2÷100
#     前半 r·q1 ≤ |M|(安全), 后半 r·r2 ≤ 9801(恒安全)。
#   ★ 顺序: 先取 M 的商/余, 再用**还等于 r 的** #lo 算 r·r2, 最后才把 #lo 换成 r·q1。
$scoreboard players operation #q1 $(obj) = $(mul) $(obj)
$scoreboard players operation #q1 $(obj) /= #100 manacore.meta
$scoreboard players operation #t $(obj) = #q1 $(obj)
$scoreboard players operation #t $(obj) *= #100 manacore.meta
$scoreboard players operation #r2 $(obj) = $(mul) $(obj)
$scoreboard players operation #r2 $(obj) -= #t $(obj)
$scoreboard players operation #t $(obj) = #lo $(obj)
$scoreboard players operation #t $(obj) *= #r2 $(obj)
$scoreboard players operation #t $(obj) /= #100 manacore.meta
$scoreboard players operation #lo $(obj) *= #q1 $(obj)
$scoreboard players operation #lo $(obj) += #t $(obj)

# ④ 出参 = 前半 + 后半
$scoreboard players operation #mul_out $(obj) = #q $(obj)
$scoreboard players operation #mul_out $(obj) += #lo $(obj)
