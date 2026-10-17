# ============================================================
# sweetdream:equipment/armor/crimson_seam/second —— 缝心: 每秒兜底清掉「绯结」
# ------------------------------------------------------------
# 【谁调用它】挂在 #manacore:event/second（对 @a 广播）
# 【执行者】每个玩家
# 【★ 本函数只做一件事: 拆件即清 ★】用户稿总则:"拆去任一成员后, 套装增益和
#   私有积攒立即清除"。「绯结」是**私有积攒**(0..3 层), 只在"两件齐"时才有意义。
#   包内对"拆件即清"的既有做法就是**每秒重算**(9 套先例皆如此, 拆件后最多 1 秒
#   内生效) —— 「绯结」没有条件驱动的常驻形态, 所以单开这一支每秒清一遍。
#   ★ 为什么不能只靠 knit_add 那一处惰性清 ★
#     惰性清只在"下一次附加噬心"时才跑。玩家拆掉头盔 -> 什么都不做 -> 再装回来,
#     中间没有任何事件 ⇒ 层数原样留着 = "撤装再装能保住绯结", 违反总则。
#     单靠这一个每秒件不够吗? 够 —— knit_add 那次是"顺手再判一次"的保险, 不是必需。
# 【★ 只对"确实有层数"的人写 ★】本函数被广播给 @a, 绝大多数玩家是 0 层;
#   加 `if score … matches 1..` 就不会每秒给全体玩家凭空建一个计分项。
# 【★ 只清层数, **不**清节流 ★】zx.cr_knit_cd(6 秒积攒节流) / zx.cr_amp_cd(5 秒
#   强化节流) 是"多久内最多一次"的节流账本, 不是积攒; 拆件时把它们归零 =
#   "撤装再装就能重置冷却", 那反而变成漏洞。
# ============================================================

# 拆掉针眠（头盔）-> 层数归零
execute if score @s zx.cr_knit matches 1.. unless items entity @s armor.head *[minecraft:custom_data~{zx:["needle_sleep"]}] run scoreboard players set @s zx.cr_knit 0
# 拆掉绯缝（胸甲）-> 层数归零
execute if score @s zx.cr_knit matches 1.. unless items entity @s armor.chest *[minecraft:custom_data~{zx:["crimson_seam"]}] run scoreboard players set @s zx.cr_knit 0
