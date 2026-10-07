# ============================================================
# sweetdream:equipment/tool/blaze_plume/find_victim —— 钉死"刚才打的是哪一只"
# ------------------------------------------------------------
# 【宏参数】zx:work bpv {u0,u1,u2,u3} —— 动手玩家的 UUID 四个整数
# 【执行者】玩家(函数体不用 @s, 只用选择器)
# 【产出】给命中的那一只挂标签 zx.bp_t
# 【两个条件同时成立(同 styx_walk/find_victim)】
#   ① nbt={last_hurt_by_player:[I;…]} —— 生物自己记的"最近打我的是哪个玩家"。
#   ② HurtTime 10 / 9 —— 排掉"这个玩家 5 秒内打过的其它怪", 只留刚才那一下。
# 【★ 标签用自己的 zx.bp_t ★】不借 styx_walk 的 zx.sw_t —— 两件装备可能同 tick
#   触发, 各用各的标签才不会互相踩。
# ============================================================

$execute as @e[type=!#sweetdream:no_damage,nbt={HurtTime:10s,last_hurt_by_player:[I;$(u0),$(u1),$(u2),$(u3)]},sort=nearest,limit=1] run tag @s add zx.bp_t
$execute unless entity @e[tag=zx.bp_t,limit=1] as @e[type=!#sweetdream:no_damage,nbt={HurtTime:9s,last_hurt_by_player:[I;$(u0),$(u1),$(u2),$(u3)]},sort=nearest,limit=1] run tag @s add zx.bp_t
