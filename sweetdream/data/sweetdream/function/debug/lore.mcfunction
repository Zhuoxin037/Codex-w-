# ============================================================
# sweetdream:debug/lore —— 重刷**副手**物品的描述(lore)
# ------------------------------------------------------------
# 【用法】/function sweetdream:debug/lore    （物品拿在副手）
# 【什么时候用】世界里已经敲过升级 / 超限的老物品, 它们的描述是**旧版**规则
#   写的(那时候超限只追加一行, 不会整段换掉)。改完规则之后老物品不会自己变,
#   用它刷一遍就行 —— 不用重新给、也不用重新敲。
# 【它做的事】副手 -> 工作台那一格 -> station/api/lore_refresh -> 回到副手。
#   和敲装备走的是同一条重建线, 所以结果是幂等的: 刷几次都一样。
# 【★ 不会白吃材料 ★】这里不调 fit, 也不动 up / ol, 只重建描述。
# 【工作台那一格】就是强化台用的 0,-59,2 的箱子(没有就先放一个)。
# ============================================================

data modify storage zx:work st set value {x:0,y:-59,z:2}

execute unless items entity @s weapon.offhand * run tellraw @s [{"text":"[调试] 副手是空的 —— 把要刷新描述的装备拿在副手","color":"red"}]
execute unless items entity @s weapon.offhand * run return 0

execute unless block 0 -59 2 #minecraft:shulker_boxes unless block 0 -59 2 minecraft:chest run setblock 0 -59 2 minecraft:chest replace

item replace block 0 -59 2 container.0 from entity @s weapon.offhand
function sweetdream:station/api/lore_refresh with storage zx:work st
item replace entity @s weapon.offhand from block 0 -59 2 container.0

tellraw @s [{"text":"[调试] 副手物品的描述已按当前规则重建","color":"green"}]
