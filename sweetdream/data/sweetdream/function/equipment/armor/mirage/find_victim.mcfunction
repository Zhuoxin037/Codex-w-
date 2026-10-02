# ============================================================
# sweetdream:equipment/armor/mirage/find_victim —— 钉死"刚才打的是哪一只"
# ------------------------------------------------------------
# 【宏参数】zx:work mr_v {u0,u1,u2,u3}  —— 动手玩家的 UUID 四个整数
# 【执行者】玩家(函数体不用 @s, 只用选择器)
# 【产出】给命中的那一只挂上标签 zx.mr_t
# 【两个条件同时要满足】
#   ① nbt={last_hurt_by_player:[I;…]} —— 生物自己记的"最近打我的是哪个玩家",
#      原版在**受伤那一刻**就写好了(为了怪报复玩家), 5 秒后才清。
#      这是精确键, 不是"就近猜": 两个人各打各的怪也不会串。
#   ② HurtTime 10 / 9 —— 把"这个玩家 5 秒内打过的其它怪"排掉, 只留"刚才这一下"。
#      分两行是兜时机: 进度有可能在伤害结算的同一 tick 跑(那时 HurtTime=10),
#      也可能晚一 tick(9)。
# 【limit=1 + sort=nearest】AOE 一下打中好几只时只挑最近的 —— 文案是"对其"(单只)。
# 【这个函数成不成, 不影响主流程】没命中就什么都不打标签, attack 那边还有
#   老办法兜底, 所以这里不需要报错或提示。
# ============================================================

$execute as @e[type=!#sweetdream:no_damage,nbt={HurtTime:10s,last_hurt_by_player:[I;$(u0),$(u1),$(u2),$(u3)]},sort=nearest,limit=1] run tag @s add zx.mr_t
$execute unless entity @e[tag=zx.mr_t,limit=1] as @e[type=!#sweetdream:no_damage,nbt={HurtTime:9s,last_hurt_by_player:[I;$(u0),$(u1),$(u2),$(u3)]},sort=nearest,limit=1] run tag @s add zx.mr_t
