# ============================================================
# sweetdream:equipment/axe/draught/ol_expire —— 第二形态的 10 秒计时推进
# ------------------------------------------------------------
# 【谁调用它】lib/second: execute as @a[scores={zx.dg_on2=1..}] run function ...
# 【执行者】玩家
# 【做什么】① 剩余秒 -1; ② 还有剩就收工; ③ 到点撤掉本形态叠的基础攻击力。
#   ★ 必须在本函数里把"减到 0 之后"的撤除也做完 —— 外面那条筛选是 dg_on2=1..,
#     减成 0 之后这个人下一拍就不再被选中, 没有第二次机会(同 draught/expire)。
#   ★ 与第一形态(expire/zx.dg_on)是两条独立的线: 第一形态的 12 秒加成即使
#     第二形态已经结束也照样跑完自己的表。
# ============================================================

scoreboard players remove @s zx.dg_on2 1
execute if score @s zx.dg_on2 matches 1.. run return 0

function sweetdream:equipment/axe/draught/ol_strip
tellraw @s [{"text":"饮鸩·第二形态: 攻击力加成已消退","color":"gray"}]
