# ============================================================
# sweetdream:equipment/armor/resonance/hook_calc —— 共振: 每个术阵 +10% 技能伤害
# ------------------------------------------------------------
# @calc: add     ← 这是"加算"型 hook: 只往加算池里写百分比, 由 lib/dmg_add_apply 统一乘
# 【谁调用它】#manacore:event/damage_calc —— 前置包在每次 api/damage/calc
#   算完之后抛的事件(标签在 sweetdream/data/manacore/tags/function/event/)。
# 【★ 执行者就是施法者本人 ★】function 命令不改变 @s, 所以从技能 -> calc ->
#   事件这一路传下来, @s 一直是那个放技能的人。这正是它能直接查 armor.chest
#   的原因(不需要再按 uuid 反查玩家)。
#   ⚠️ 万一被非玩家调用(法球 / 箭 / 命令方块), 第 ⓪ 步直接退出 —— 不判的话
#       `items entity @s armor.chest` 在非玩家身上会失败并截断整个函数。
# 【为什么挂在 calc 里, 而不是每秒快照一次】文案是"**当前**每有一个术阵":
#   必须是施法那一刻的数量。每秒快照会在术阵刚生成 / 刚过期的那一秒算错,
#   而且多玩家时快照还会串味。挂在 calc 上永远读到的是"这一次施法"的真实值。
# 【★★ 加算, 不是独立乘区 ★★(2026-10-06 改)】
#   文案"每有一个 +10%"是**百分比相加**: n 个术阵 = ×(1 + 0.1n)。
#   所以这里只把 10n 写进加算池 zx:work add 的三条通道, 由 lib/dmg_add_apply
#   在事件末尾**统一乘一次**。这样它和漫步冥河(+30%)等其他加算叠加时是
#     ×(1 + 0.1n + 0.3)        ← 正确(加算)
#   而不是
#     ×(1 + 0.1n) × 1.3        ← 旧写法(各自乘一次 = 独立乘区), 偏大
#   几种加成都在池子里相加, 谁也不比谁"乘得早"。
# 【为什么"不挑口径"交给 lib/dmg_add_put_any(D01 口径 B)】
#   文案是"技能的伤害 +10%" —— 不挑通道。伤害侧是**分量级**(各段各乘各的),
#   所以要让整段 +10n% 就得**三条通道各写一份**(Σseg_i×(1+X)=整段×(1+X))。
#   (旧 F14 的"只写一条"是**汇总式**遗留: 那时三条相加会重复计入; 分段式下
#    三条各乘各的段, 不会重复 —— 详见 lib/dmg_add_put_any 头注释。)
# ============================================================

# ⓪ 不是玩家(法球 / 箭 / 命令方块在算伤害) -> 不参与
execute unless entity @s[type=minecraft:player] run return 0

# ① 穿着共振吗(没穿就什么都不做 —— 这是"@a 广播型"逻辑必须自己判的一条)
execute unless items entity @s armor.chest *[minecraft:custom_data~{zx:["resonance"]}] run return 0

# ② 数术阵; 一个都没有的话, 加 0% 是白绕一圈, 直接走人
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail
data modify storage manacore:in arg set value {uuid:""}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/formation/count
execute store result score #n zx.meta run data get storage manacore:out r.count
execute unless score #n zx.meta matches 1.. run return 0

# ③ 百分比 = 10 × 术阵数(#pct = 10n, 单位就是"百分点")
#    别把 #n 就地乘掉 —— 后面还要拿它判断术阵数(就地改共享假玩家是最容易埋雷的写法)。
scoreboard players operation #pct zx.meta = #n zx.meta
scoreboard players operation #pct zx.meta *= #10 zx.meta

# ④ 写进加算池: 交给 lib/dmg_add_put_any —— 它给 mm/atk/oth **三条各写一份** 10n
#    (D01 口径 B: 伤害侧分量级, 三条各乘各的段 ⇒ 整段 +10n%; 写出没被用到的
#     通道是安全的, 那段 seg = 0)。见该文件头注释的 F14/B 说明。
#    ★ 不再直接乘 r.damage ★ 那是"独立乘区"的落点, 会让共振和漫步冥河相乘。
execute store result storage zx:work put.pct int 1 run scoreboard players get #pct zx.meta
function sweetdream:lib/dmg_add_put_any
