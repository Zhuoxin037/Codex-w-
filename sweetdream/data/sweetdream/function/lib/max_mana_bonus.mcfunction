# ============================================================
# sweetdream:lib/max_mana_bonus —— 把"下一次技能加成"乘进技能倍率
# ------------------------------------------------------------
# 【宏参数】任意含 uuid 的节点(通常是 zx:work wg)   【执行者】施法者
# 【这个加成从哪来】风行于大地之上: 「风声」超过 60 时, 每超出 1 点让
#   "下一次以最大魔力结算的技能伤害" +1%。存在 zx:data wg_bonus."<uuid>"。
#
# 【★ 它是"普通乘区"不是"独立乘区" ★】
#   文案说的是"技能伤害提升 1%", 属于**技能倍率**那一档 ——
#   所以乘进 manacore:in arg.skill_multiplier, 而不是 independent_multiplier。
#   独立乘区是"所有加成算完之后再统一乘一次", 性质完全不同, 用错会算多。
#
# 【谁该调用它】所有"以最大魔力结算"的技能, 在填好 skill_multiplier、
#   调用 api/damage/calc **之前**调一次即可:
#     data modify storage zx:work wg.uuid set from storage zx:data self.uuid
#     function sweetdream:lib/max_mana_bonus with storage zx:work wg
#   目前已接: 横刀(dash_end)、风行于大地之上的爆发(hit_pass)。
#   ⚠️ 风行**回响(aura_hit)故意不接** —— 它是本次施法的收尾, 不是"下一次技能",
#      接了的话加成 1 秒后就被它吃掉, 永远轮不到下一次施法。
#   ⚠️ 深海**不要**接 —— 它的伤害口径是"当前魔力 ×0.15", 不是最大魔力。
#
# 【存的是"合计"】wg_bonus 里是**已经加算好的总加成**(0.4 = +40%),
#   多个来源(或连续攒到两次)在 bonus 那边就先把百分比加在一起了,
#   这里只需要"总加成 + 100%, 再乘一次技能倍率" —— 也就是加算, 不是各自乘一遍。
# 【只生效一次】乘完立刻把 wg_bonus 删掉 —— 所以它是"一次性"的:
#   攒到之后, 谁第一个用上就被谁吃掉(顺带发一条提示, 不然它完全是隐形的)。
# 【怎么乘】NBT 里的 double 不能直接相乘, 所以按框架的老办法走计分板定点:
#   技能倍率按 x100 取值, 加成也按 x100, 相乘后除回 100。
# ============================================================

# 身上没有加成 -> 什么都不做
$execute unless data storage zx:data wg_bonus."$(uuid)" run return 0

execute store result score #sm manacore.math run data get storage manacore:in arg.skill_multiplier 100
$execute store result score #b manacore.math run data get storage zx:data wg_bonus."$(uuid)" 100
scoreboard players add #b manacore.math 100
scoreboard players operation #sm manacore.math *= #b manacore.math
scoreboard players operation #sm manacore.math /= #100 manacore.meta
execute store result storage manacore:in arg.skill_multiplier double 0.01 run scoreboard players get #sm manacore.math

# 把"这一下吃了多少加成"告诉玩家 —— 不加这句的话, 这份加成从攒到到被吃掉
# 之间只有极短的一瞬间, 你根本看不到它生效(排查困扰了很久)。
scoreboard players operation #pct manacore.math = #b manacore.math
scoreboard players remove #pct manacore.math 100
tellraw @s [{"text":"风声加成 +","color":"aqua"},{"score":{"name":"#pct","objective":"manacore.math"},"color":"white"},{"text":"% 已计入本次技能伤害","color":"aqua"}]

$data remove storage zx:data wg_bonus."$(uuid)"
