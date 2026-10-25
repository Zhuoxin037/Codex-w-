# ============================================================
# sweetdream:equipment/sword/myriad/in_domain_go —— 宏: 按 UUID 找"我的领域"
# ------------------------------------------------------------
# 【宏参数】zx:work mqh {u0,u1,u2,u3} = 玩家 UUID 四个整数
# 【执行者】玩家(@s 一直是玩家; 中间那段 as @e 不会改变后续命令的 @s)
# 【判据】存在一只属于我的领域 marker(写了我的 UUID), 且我离它 <= 5 格。
#   ★ 半径写死 5 —— 文案给的就是"半径为 5 格", 没有第二档数值。
# ============================================================

$data modify storage zx:work ub set value {u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}
function sweetdream:lib/u_by
execute as @e[tag=zx.mq_f] at @s if entity @a[distance=..5,tag=zx.ub,limit=1] run scoreboard players set #mq_in zx.meta 1
