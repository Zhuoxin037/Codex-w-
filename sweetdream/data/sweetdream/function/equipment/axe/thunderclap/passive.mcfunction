# ============================================================
# sweetdream:equipment/axe/thunderclap/passive —— 威霆「天煌」: 每刻积攒
# ------------------------------------------------------------
# 【谁调用它】core/tick: execute as @a at @s run function 本函数
# 【技能原文(必须和这里对上)】
#   "自身手持该武器且未攻击生物时，每刻积攒一点「天煌」（上限 2000 点）。"
# 【★ 四要素 ★】① 触发: 每游戏刻; ② 范围: 手持威霆时(主手或副手); ③ 每刻 +1; ④ 上限 2000。
# 【"未攻击"怎么表达】攻击生物那一下由 hit 把 zx.tc_n 清 0 —— "攻击就清零"天然等价于
#   "只有没在攻击的时候才在攒"。不需要额外的"最近攻击过"计时。
# ============================================================

execute unless items entity @s weapon.mainhand netherite_axe[custom_data~{zx:["thunderclap"]}] unless items entity @s weapon.offhand netherite_axe[custom_data~{zx:["thunderclap"]}] run return 0
execute if score @s zx.tc_n matches 2000.. run return 0
scoreboard players add @s zx.tc_n 1
