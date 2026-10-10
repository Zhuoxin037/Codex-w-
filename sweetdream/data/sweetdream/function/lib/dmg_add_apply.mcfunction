# ============================================================
# sweetdream:lib/dmg_add_apply —— 把"加算池"统一乘一次(damage_calc 事件倒数第二步)
# ------------------------------------------------------------
# 【谁调用它】#manacore:event/damage_calc —— 排在**所有加算 hook 之后、独立乘区之前**。
# 【它做什么】把池子 zx:work add 里那几条百分比**先加在一起, 再对 r.damage 乘一次**:
#     伤害 × (1 + Σ b)
#   —— 这就是"加算"的正确落点(旧写法是每件装备各乘一次 = 独立乘区)。
# 【★ 只吃"本次技能真正用到的那条通道"★】
#   判断依据是快照 zx:work ch(calc 抛事件时的三条通道值): 哪条非 0, 就是这次技能
#   走的那条。于是:
#     · "有关最大魔力值的技能"专用加成(漫步 +30%) 打在 mm 上 -> 攻击力类技能吃不到 ✔
#     · 共振(+10%/阵)往三条通道都写了 -> 只有被用到的那条会生效 ✔
#     · 炽天使(+50%) 打在 atk 上 -> 最大魔力类技能吃不到 ✔
#   ★ 多通道技能(mm+atk 各出一部分)不会再把同一份百分比重复计入 ——
#     口径在**写池端**锁死: 不挑口径的加成走 lib/dmg_add_put_any, 它只写
#     "第一条用到的通道"; 挑口径的加成(漫步写 mm / 炽天使写 atk)本来就只写一条。
#     于是这里"把用到的通道相加"永远加的是**各不相同**的几份贡献。
#     (2026-10-10 修 F14 —— 旧写法是每个"不挑口径"的 hook 都写满三条,
#      多通道技能会算成 ×(1+2X); 详见 lib/dmg_add_put_any 头注释。)
# 【为什么不用"每条通道各乘一次"】那会退化成乘法(×(1+b1)(1+b2)), 就不是加算了。
# 【定点】百分比按 ×100 读成整数(0.10 -> 10); r.damage 也 ×100; 中间量在 int32 内。
# 【出参】无 —— 直接改 manacore:out r.damage。
# ============================================================

# ① 三条通道: "本次技能用到(ch.<c> != 0)" 且 "有加算贡献(add.<c> != 0)" 才累加
scoreboard players set #ax zx.meta 0

# --- 最大魔力值通道 ---
scoreboard players set #u zx.meta 0
execute store result score #u zx.meta run data get storage zx:work ch.max_mana_mul 100
scoreboard players set #a zx.meta 0
execute if score #u zx.meta matches 1.. store result score #a zx.meta run data get storage zx:work add.mm 100
scoreboard players operation #ax zx.meta += #a zx.meta

# --- 基础攻击力通道 ---
scoreboard players set #u zx.meta 0
execute store result score #u zx.meta run data get storage zx:work ch.attack_mul 100
scoreboard players set #a zx.meta 0
execute if score #u zx.meta matches 1.. store result score #a zx.meta run data get storage zx:work add.atk 100
scoreboard players operation #ax zx.meta += #a zx.meta

# --- 其他通道(当前魔力结算那类) ---
scoreboard players set #u zx.meta 0
execute store result score #u zx.meta run data get storage zx:work ch.other_mul 100
scoreboard players set #a zx.meta 0
execute if score #u zx.meta matches 1.. store result score #a zx.meta run data get storage zx:work add.oth 100
scoreboard players operation #ax zx.meta += #a zx.meta

# ② 一条贡献都没有 -> 走人(不能白绕一圈定点运算)
execute unless score #ax zx.meta matches 1.. run return 0

# ③ r.damage × (100 + #ax) / 100
scoreboard players set #k zx.meta 100
scoreboard players operation #k zx.meta += #ax zx.meta
scoreboard players set #d zx.meta 0
execute store result score #d zx.meta run data get storage manacore:out r.damage 100
# 【★ R05 整数上界保护(2026-10-10)★】
#   #d = r.damage ×100, 下一步 ×#k(= 100 + 加成百分点), 中间值是 int32。
#   这里 #k 是**动态**的(多个百分比加成叠加), 所以上限也得动态算: INT32_MAX ÷ #k。
#   例: 只叠 +15%(#k=115)时上限 = 18,673,767(即 186,737 伤害); 叠到 +500% 时相应收紧。
#   越过上界会**回绕成负数**(不报错) —— 极端加成一身时伤害反而变成负的。
#   ★ 同 vuln_tag 那条注释: 不改成"先 ÷100 再 ×#k", 那会让常态丢掉两位小数精度。
scoreboard players set #d_cap zx.meta 2147483647
scoreboard players operation #d_cap zx.meta /= #k zx.meta
execute if score #d zx.meta > #d_cap zx.meta run scoreboard players operation #d zx.meta = #d_cap zx.meta

scoreboard players operation #d zx.meta *= #k zx.meta
scoreboard players operation #d zx.meta /= #100 zx.meta
execute store result storage manacore:out r.damage double 0.01 run scoreboard players get #d zx.meta
