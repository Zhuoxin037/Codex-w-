# ============================================================
# sweetdream:equipment/axe/chenyuan/ol_next —— 超限·沉渊: "下一个最大魔力技能 +10%"
# ------------------------------------------------------------
# 【挂在哪】#manacore:event/damage_calc, 排在 lib/mm_add/hook_calc **之后**、
#   lib/dmg_add_apply **之前**(加算型 hook 写在 apply 之后 = 百分比永远乘不上)。
# @calc: add
# 【设计原文】"...若其已附加则改为为自身恢复 80 魔力值并使自身下一次释放技能
#   最大魔力值相关的技能时伤害 +10%（不可叠加）。"
# 【★ 与 zx.mm_add 的区别 ★】mm_add 是"最大魔力值技能倍率"那条通用加算池
#   (风生/忘川彼岸/无效共用), 自己就是一份常驻的百分比; 这里是**一次性的**
#   10 个百分点, 兑现一次就没了。两者**加算**在一起是预期的(不同来源)。
# 【★ 不可叠加 = 重复触发只保留一份 ★】再次触发只把 zx.cy_mmn 设回 1,
#   绝不做 `add` —— 否则打两次就变 +20%。
# 【★ 同刻去重 ★】一次技能可能触发多次 damage_calc(多段/多目标), 都算"同一个
#   下一次"。用 zx.cy_mml 记住消费的那一 tick, 同刻后续几跳直接跳过。
# 【★ 判定 "走没走 mm 通道" 与 lib/mm_add/take 同一口径 ★】读快照
#   zx:work ch.max_mana_mul(非 0 才是这次真的用了最大魔力值)。
#   平平A / 当前魔力类 / 基础攻击力类吃不到, 也不该把它用掉。
# ============================================================

# ① 不是玩家(法球 / 箭 / 命令方块在算伤害) -> 不参与
execute unless entity @s[type=minecraft:player] run return 0

# ② 身上没有待兑现的那一份 -> 不参与
execute unless score @s zx.cy_mmn matches 1.. run return 0

# ③ 本次真的走了最大魔力值通道吗
scoreboard players set #cyn zx.meta 0
execute store result score #cyn zx.meta run data get storage zx:work ch.max_mana_mul 100
execute unless score #cyn zx.meta matches 1.. run return 0

# ④ 同刻已经兑现过 -> 这次是同一次技能的后续几跳, 不再加一份
execute if score @s zx.cy_mml = #now manacore.meta run return 0
scoreboard players operation @s zx.cy_mml = #now manacore.meta

# ⑤ 往加算池的 mm 通道写 10 个百分点(与 mm_add 同一条流水线, 加算)
scoreboard players set #cyn_p zx.meta 10
execute store result storage zx:work put.pct int 1 run scoreboard players get #cyn_p zx.meta
data modify storage zx:work put.ch set value "mm"
function sweetdream:lib/dmg_add_put with storage zx:work put

# ⑥ 吃掉(池子是独立 storage, 清计分项不影响本次已经写进去的 10%)
scoreboard players set @s zx.cy_mmn 0
