# ============================================================
# sweetdream:equipment/sword/myriad/ol_second —— 超限·万念 的每秒入口
# ------------------------------------------------------------
# 【挂在哪】#manacore:event/second(每秒只跑一次, 所以裸 @e 跨维度搜索是安全的)
# 【管四件事】① 领域寿命 ② 居合倒计时 ③ 特殊技能窗口倒计时 ④ 剑魂的持有判定
# 【★ 为什么必须 at @s ★】只写 execute as 不换坐标, 里面的 distance 全算错。
# ============================================================

function sweetdream:lib/in_bak

execute as @e[tag=zx.mq_f] at @s run function sweetdream:equipment/sword/myriad/domain_tick
execute as @a[scores={zx.mq_ju=1..}] at @s run function sweetdream:equipment/sword/myriad/ju_tick
execute as @a[scores={zx.mq_win=1..}] at @s run function sweetdream:equipment/sword/myriad/win_tick
# 剑魂: 手里没有这套武器了就清零(不需要坐标, 纯看两个手槽)
execute as @a[scores={zx.mq_soul=1..}] run function sweetdream:equipment/sword/myriad/soul_lost

function sweetdream:lib/in_restore
