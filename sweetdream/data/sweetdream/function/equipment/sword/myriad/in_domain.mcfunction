# ============================================================
# sweetdream:equipment/sword/myriad/in_domain —— 我站在"自己的"领域里吗
# ------------------------------------------------------------
# 【出参】#mq_in zx.meta = 1 / 0   【执行者】玩家
# 【为什么要独立成一个文件】"处于领域中"这个判据在本武器的三处都要用:
#   ① 平A计数(on_hit) ② 特殊技能能不能放(cast 的窗口分支) ③ 特殊技能打谁(special)。
#   三处各手写一遍谓词 = 以后改半径/改判据必漏一处(见 RULES 的"一行炸=整函数废"
#   精神: 漏改不会报错, 只会静默不一致)。所以只写这一份。
# 【★ 按 UUID 认人 ★】场上可能同时有别人的领域(多人各放一次), 只看
#   "离某只领域 marker 近不近"会把别人的领域认成自己的。
# ============================================================

scoreboard players set #mq_in zx.meta 0
execute unless entity @e[tag=zx.mq_f,limit=1] run return 0

execute store result storage zx:work mqh.u0 int 1 run data get entity @s UUID[0]
execute store result storage zx:work mqh.u1 int 1 run data get entity @s UUID[1]
execute store result storage zx:work mqh.u2 int 1 run data get entity @s UUID[2]
execute store result storage zx:work mqh.u3 int 1 run data get entity @s UUID[3]
function sweetdream:equipment/sword/myriad/in_domain_go with storage zx:work mqh
