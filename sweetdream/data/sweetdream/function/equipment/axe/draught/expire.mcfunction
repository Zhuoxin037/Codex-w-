# ============================================================
# sweetdream:equipment/axe/draught/expire —— 饮鸩的加成每秒推进 / 到期撤除
# ------------------------------------------------------------
# 【谁调用它】lib/second: execute as @a[scores={zx.dg_on=1..}] run function ...
# 【执行者】玩家
# 【做什么】① zx.dg_on -1; ② 还没到 0 就收工; ③ 到 0 就撤掉加成(strip) + 提示。
#   ★ 必须在本函数内把"减到 0 之后"的撤除也做完: 外面那条筛选是 zx.dg_on=1..,
#     减成 0 之后这个人下一拍就不再被选中了, 外面没有第二次机会。
# ============================================================

scoreboard players remove @s zx.dg_on 1
execute if score @s zx.dg_on matches 1.. run return 0

function sweetdream:equipment/axe/draught/strip
tellraw @s [{"text":"饮鸩: 攻击力加成已消退","color":"gray"}]
