# ============================================================
# sweetdream:lib/victim_go —— lib/victim 的宏层(拼 UUID 进选择器)
# ------------------------------------------------------------
# 【宏参数】zx:work v {u0,u1,u2,u3}   【执行者】玩家
#   ⚠️ 必须 with storage zx:work v —— 传 zx:data self 会让宏函数一条命令都不跑(静默)。
# 【产出】给命中的那一只挂 zx.victim(最近的一只)
# ============================================================

$execute as @e[type=!#sweetdream:no_damage,nbt={HurtTime:10s,last_hurt_by_player:[I;$(u0),$(u1),$(u2),$(u3)]},sort=nearest,limit=1] run tag @s add zx.victim
$execute unless entity @e[tag=zx.victim,limit=1] as @e[type=!#sweetdream:no_damage,nbt={HurtTime:9s,last_hurt_by_player:[I;$(u0),$(u1),$(u2),$(u3)]},sort=nearest,limit=1] run tag @s add zx.victim
