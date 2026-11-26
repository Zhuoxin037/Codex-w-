# ============================================================
# fallendream:equipment/armor/still_sky/layer_add —— 超限: 加一层「星帷」(最多 3)
# ------------------------------------------------------------
# 【执行者】玩家
# 【★ 先判空位、再写 ★】写成"没满就写第 1 格"再接着判第 2 格, 会在刚写完的
#   那一格上重新判一次(它已经变成"满"了), 于是永远加不到第二层。
#   #s2_done 记住"这次填了哪一格", 填过就跳过后面的空位检查。
# ============================================================
scoreboard players operation #s2_l1 zx.meta = #now manacore.meta
scoreboard players add #s2_l1 zx.meta 320

scoreboard players set #s2_done zx.meta 0
execute unless score @s zx.s2_sky1 > #now manacore.meta run scoreboard players set #s2_done zx.meta 1
execute if score #s2_done zx.meta matches 1 run scoreboard players operation @s zx.s2_sky1 = #s2_l1 zx.meta
execute if score #s2_done zx.meta matches 0 unless score @s zx.s2_sky2 > #now manacore.meta run scoreboard players set #s2_done zx.meta 2
execute if score #s2_done zx.meta matches 2 run scoreboard players operation @s zx.s2_sky2 = #s2_l1 zx.meta
execute if score #s2_done zx.meta matches 0 unless score @s zx.s2_sky3 > #now manacore.meta run scoreboard players set #s2_done zx.meta 3
execute if score #s2_done zx.meta matches 3 run scoreboard players operation @s zx.s2_sky3 = #s2_l1 zx.meta

particle minecraft:enchant ~ ~1 ~ .4 .3 .4 0 12 normal
