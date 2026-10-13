# ============================================================
# sweetdream:equipment/armor/ember/top_up —— 已经带「夜火」的目标熄灭时补「流火」
# ------------------------------------------------------------
# 【执行者】目标生物   【谁调用】burned_out ②（只在它身上已有夜火时才进来）
# 【文案】"若自身 9 格内有生物的燃烧状态结束, 则使其附着「流火」。" ——
#   文案**没有**排除"已经有夜火"的情况。旧版 `burned_out` 在这里直接
#   `if entity @s[tag=zx.status.yehuo] run return 0`(保持最高阶), 于是穿余烬
#   永远看不到"流火 + 夜火"(用户 2026-10-12 实测: "夜火怪再燃烧后没有附加流火")。
#   拍板口径: 夜火怪再熄灭**也要**补流火 —— 两个标签本来就互相独立
#   (tag/mark_one 各管各的, 倒计时也是两套), 双状态是合法的。
# 【★ 已经有流火 = 已经是双状态 -> 什么都不做 ★】
#   保持"最高阶不再变"的语义: 不重贴、不刷新、不降级（与旧 ② 的行为一致）。
# 【★★ 节流护栏 —— 这段是必需的, 删了就是刷魔力漏洞 ★★】
#   双状态被"吸收"（烈火残躯 的 night / 红莲 的 step_night 把夜火摘走）之后
#   只剩一个流火, 下次熄灭又会把它升级成夜火 -> 反复给余烬回 100 魔力。
#   而这条"补流火"正是那个循环**唯一**能自我重新武装的来源（夜火本身不会自己长出来）,
#   所以对它限速: 同一只生物 100 刻(5 秒)最多补一次。
#   `zx.em_gate` = 该生物"下次可以补"的 tick 时刻（#now = manacore 的 tick 计数）。
#   ★ 原有那两支（无 -> 流火 / 流火 -> 夜火）**不节流**, 保持旧手感:
#     它们不构成"自己给自己续杯"的闭环, 燃料只有玩家真的点火那一下。
# ============================================================

# ① 已经有流火 -> 已经是"流火 + 夜火", 保持不动
execute if entity @s[tag=zx.status.liuhuo] run return 0

# ② 节流: 还没到"下次可补"的时刻 -> 收工
#   ★ 先 add 0 把没分数的目标补成 0 —— 计分项"没分数"时 `if score` 判**不成立**,
#     不能靠"没分数"来表达"从没补过"(那样第一次永远补不上)。
scoreboard players add @s zx.em_gate 0
execute if score @s zx.em_gate > #now manacore.meta run return 0

# ③ 记下"下次可补"的时刻 = 现在 + 100 刻(#100 = 5 秒, 见 core/load 常量表)
scoreboard players operation @s zx.em_gate = #now manacore.meta
scoreboard players operation @s zx.em_gate += #100 zx.meta

# ④ 附着「流火」—— 通用标签接口: 目标就是当前 @s
#   ★ 与 burned_out ⑤⑥ 同一口径: 这里**故意**不走 lib/mark_consume(消耗统一入口),
#     因为这是"附着"而不是"消耗", 走入口会把执行者(玩家)当成消耗者、白给余烬被动。
data modify storage zx:work ic.target set value "@s"
data modify storage zx:work ic.mark set value "liuhuo"
function sweetdream:tag/mark with storage zx:work ic
scoreboard players add #em_conv zx.meta 1
