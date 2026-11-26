# @calc: add — 归息(超限)「下一次其他技能伤害 +10%」: 只写 oth 通道, 兑现一次
# ------------------------------------------------------------
# 【谁调用它】#manacore:event/damage_calc —— 排在 lib/dmg_add_apply **之前**
#   (加算型 hook 写在 apply 之后 = 这份百分比永远不会被算上, 静默失效)
# 【文案(逐字)】"…消耗的若是「噬心」，则使自身下一次其他技能伤害 +10%。"
# 【★ "其他技能" 只认 oth 通道 ★】与「剖面」give 头注释同一口径:
#   "下一次其他技能伤害（当前魔力、生命值等倍率）"= 只挂 oth, 挂上去一直保留,
#   直到真的打出一次走 oth 通道的技能才消费; mm / atk / 固定伤害都不消耗它。
#   (不能拿 lib/mm_add 的 zx.mm_add —— 那条只作用在**最大魔力值**通道的技能上。)
# 【★ 判 "这次走了 oth" ★】读 calc 落好的 r.seg_o: 为 0 就说明这一击没有 oth 分量,
#   保持待发、不消费。
# ============================================================

# ⓪ 不是玩家(法球 / 箭 / 命令方块在算伤害) -> 不参与
execute unless entity @s[type=minecraft:player] run return 0

# ① 没有待发加成 -> 不参与
execute unless score @s zx.lb_om matches 1.. run return 0

# ② 本次结算没有 oth 分量 -> 保留待发
scoreboard players set #lbo_d zx.meta 0
execute store result score #lbo_d zx.meta run data get storage manacore:out r.seg_o
execute if score #lbo_d zx.meta matches ..0 run return 0

# ③ 写进加算池的 oth 通道
execute store result storage zx:work put.pct int 1 run scoreboard players get @s zx.lb_om
data modify storage zx:work put.ch set value "oth"
function fallendream:lib/dmg_add_put with storage zx:work put

# ④ 吃掉(这次技能已经吃到, "下一次"用完了)
scoreboard players set @s zx.lb_om 0
