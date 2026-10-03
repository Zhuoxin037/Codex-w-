# ============================================================
# sweetdream:debug/equip_scan —— 扫一个槽位, 把装备 id 记进"在身名单"
# ------------------------------------------------------------
# 【宏参数】{p}      【执行者】玩家本人
#   p = 这个槽位的 NBT 路径(SelectedItem / equipment.offhand / equipment.head /
#       equipment.chest / equipment.legs / equipment.feet)
# 【干什么】把这个槽位上物品的 custom_data.zx[0](装备 id)读出来,
#   然后写 zx:work eq.<id> = 1b。
# 【给谁用】debug/stats 的"装备加成"那一段 —— 注册表每一行都有 e 字段
#   (属于哪件装备), 渲染时查 zx:work eq.<e> 在不在, 在身上才显示。
#   → **穿着什么报什么**, 不再把没穿的装备也一股脑叠上来。
# 【为什么要拆两层】id 是**运行时**读出来的字符串, 要拿它拼 storage 路径
#   只能靠宏变量, 而宏变量只能通过 with storage 传 —— 所以拆出 equip_mark。
# 【槽位路径】1.21.5 穿戴的东西在玩家 NBT 的 equipment.* 里(Inventory 的
#   100..103 已经没有了); 主手仍是 Inventory 里被选中的那格 = SelectedItem。
# ============================================================

data remove storage zx:work es

$execute if data entity @s $(p).components."minecraft:custom_data".zx[0] run data modify storage zx:work es.id set from entity @s $(p).components."minecraft:custom_data".zx[0]

execute if data storage zx:work es.id run function sweetdream:debug/equip_mark with storage zx:work es
