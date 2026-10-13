# ============================================================
# sweetdream:equipment/armor/ember/burned_out —— 燃烧刚结束时
# ------------------------------------------------------------
# 【执行者】目标生物（由 second_one 用旧标记筛出来）
# 【文案】若自身 9 格内有生物的燃烧状态结束, 则使其附着「流火」;
#         若其原本就附带「流火」, 则改为结附「夜火」。
# 【★ 旧的 data.zx.status 判定已废弃 ★】
#   现在通用标签统一是实体原生 Tags 里的 zx.status.*（由 tag/mark 维护）,
#   读旧 NBT 会导致流火/夜火判定永远不成立。
# 【★ “改为”是替换, 不是叠加 ★】(只针对"还没有夜火"的那一支)
#   有流火 -> 先摘流火, 再上夜火; 否则会出现“流火+夜火”双状态,
#   烈火残躯吸掉夜火后流火还在, 下次熄灭又能再变一次, 变成刷魔力漏洞。
# 【★ 已经有夜火的那一支 = **另补一个「流火」**(2026-10-12 用户拍板) ★】
#   文案只说“使其附着流火”, 并没有排除“已经有夜火”的情况; 旧版在这里
#   `if entity @s[tag=zx.status.yehuo] run return 0`(保持最高阶) 会把这一支吞掉,
#   于是穿余烬永远看不到“流火 + 夜火”(用户实测: “夜火怪再燃烧后没有附加流火”)。
#   现在改走 top_up: 已是双状态 -> 不动; 只有夜火 -> 补流火, **且带 5 秒节流**
#   (节流理由写在 top_up 顶部 —— 这条补流火是“吸掉夜火 -> 流火残留 -> 再升级”
#    那条刷魔力循环唯一能自我重新武装的来源)。
# ============================================================

# ① 当前还在燃烧 -> 不是“刚刚熄灭”, 什么都不做（标记留给下一秒）
execute store result score #em_f zx.meta run data get entity @s Fire
execute if score #em_f zx.meta matches 1.. run return 0

# ② 已经有「夜火」-> 保持最高阶; 并**按文案补一个「流火」**(2026-10-12 用户拍板)
#   ★ 节流(同一只生物 5 秒一次)写在 top_up 里, 别把这两行拆开或调换顺序 ——
#     先 top_up 再收工; 一旦写成"见夜火就 return", 补流火那一支立刻变死代码
#     (check.py 的 embertop 桶盯着这个顺序)。
execute if entity @s[tag=zx.status.yehuo] run function sweetdream:equipment/armor/ember/top_up
execute if entity @s[tag=zx.status.yehuo] run return 0

# ③ 判断这一只原本有没有流火
scoreboard players set #em_promote zx.meta 0
execute if entity @s[tag=zx.status.liuhuo] run scoreboard players set #em_promote zx.meta 1

# ④ 通用标签接口: 目标就是当前 @s
#   ★ 这里**故意**不走 lib/mark_consume(消耗统一入口) ★ —— 第 ⑤ 步是"把流火换成
#     夜火"的**替换**, 不是消耗: 走入口的话, 穿「永恒」的执行者会把流火补回来,
#     变成"流火+夜火"双状态(2026-10-04 记过的刷魔力漏洞), 所以保持直调 tag/unmark。
data modify storage zx:work ic.target set value "@s"

# ⑤ 原本有流火 -> 摘掉流火, 换成夜火
execute if score #em_promote zx.meta matches 1 run data modify storage zx:work ic.mark set value "liuhuo"
execute if score #em_promote zx.meta matches 1 run function sweetdream:tag/unmark with storage zx:work ic
execute if score #em_promote zx.meta matches 1 run data modify storage zx:work ic.mark set value "yehuo"
execute if score #em_promote zx.meta matches 1 run function sweetdream:tag/mark with storage zx:work ic
execute if score #em_promote zx.meta matches 1 run scoreboard players add #em_conv zx.meta 1

# ⑥ 原本两种都没有 -> 附着流火
execute if score #em_promote zx.meta matches 0 run data modify storage zx:work ic.mark set value "liuhuo"
execute if score #em_promote zx.meta matches 0 run function sweetdream:tag/mark with storage zx:work ic
execute if score #em_promote zx.meta matches 0 run scoreboard players add #em_conv zx.meta 1
