# ============================================================
# sweetdream:equipment/armor/styx_walk/find_victim —— 钉死"刚才打的是哪一只"
# ------------------------------------------------------------
# 【宏参数】zx:work sv {u0,u1,u2,u3} —— 动手玩家的 UUID 四个整数
# 【执行者】玩家(函数体不用 @s, 只用选择器)
# 【产出】给命中的那一只挂标签 zx.sw_t
# 【两个条件同时成立】
#   ① nbt={last_hurt_by_player:[I;…]} —— 生物自己记的"最近打我的是哪个玩家",
#      原版在受伤那一刻写、5 秒后清。精确键, 两个人各打各的也不会串。
#   ② HurtTime 10 / 9 —— 排掉"这个玩家 5 秒内打过的其它怪", 只留刚才那一下。
#      分两行兜时机: 进度可能在同一 tick 跑(那时 HurtTime=10), 也可能晚一 tick(9)。
# 【limit=1 + sort=nearest】一下打中好几只时只挑最近的 —— 文案是"其"(单只)。
# 【和 mirage/find_victim 同款】只是标签前缀不同, 两边互不干扰。
# ============================================================

$execute as @e[type=!#sweetdream:no_damage,nbt={HurtTime:10s,last_hurt_by_player:[I;$(u0),$(u1),$(u2),$(u3)]},sort=nearest,limit=1] run tag @s add zx.sw_t
$execute unless entity @e[tag=zx.sw_t,limit=1] as @e[type=!#sweetdream:no_damage,nbt={HurtTime:9s,last_hurt_by_player:[I;$(u0),$(u1),$(u2),$(u3)]},sort=nearest,limit=1] run tag @s add zx.sw_t
