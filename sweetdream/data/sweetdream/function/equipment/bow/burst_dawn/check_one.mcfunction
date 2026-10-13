# ============================================================
# sweetdream:equipment/bow/burst_dawn/check_one —— 数"我自己的影"(宏 {uu})
# ------------------------------------------------------------
# 【宏参数】zx:work bdc {uu} = 射手 uuid 文本
# 【执行者】射手(玩家)
# 【判据】当场数实体(不是玩家级账本) —— 影被怪打死 / 自然到期 / 换维度
#   都不会让这个数说谎。数到 0 就收尾(end)。
# 【★ 归属怎么认 ★】影身上写着主人的 uuid 文本(data.zx.bd.uu), 用 nbt 精确匹配。
#   宏参数只能取"键", 不能取列表下标(坑 129), 所以 uu 是一个**独立键**, 不是数组。
# ============================================================

scoreboard players set #bd_n zx.meta 0
$execute as @e[tag=zx.bd_shade,nbt={data:{zx:{bd:{uu:"$(uu)"}}}}] run scoreboard players add #bd_n zx.meta 1
execute if score #bd_n zx.meta matches 0 run function sweetdream:equipment/bow/burst_dawn/end with storage zx:work bdc
