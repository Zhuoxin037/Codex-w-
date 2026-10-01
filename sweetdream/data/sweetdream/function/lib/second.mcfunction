# ============================================================
# sweetdream:lib/second —— 公共件们的每秒入口(挂在 #manacore:event/second)
# ------------------------------------------------------------
# 【备份公共输入口】下面这些都会读/写 manacore:in arg, 见 lib/in_bak。
# ============================================================

function sweetdream:lib/in_bak

# 冻结/时停到点解冻
# 流光: 每秒扫"到点结算"的人 —— 取代一次性 schedule, 多人同时施法不会互相顶掉(第 3 条)
execute as @a[tag=zx.lg_casting] at @s run function sweetdream:equipment/sword/liuguang/hit_self

# 深海: 正在施法的人每秒补画一次范围环(同上)
execute if entity @a[tag=zx.de_run] run function sweetdream:equipment/sword/deepsea_echo/fx

function sweetdream:lib/unfreeze_sweep

function sweetdream:lib/in_restore
