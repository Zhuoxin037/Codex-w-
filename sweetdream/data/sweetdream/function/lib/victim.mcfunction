# ============================================================
# sweetdream:lib/victim —— 钉死"刚才这一下平A打的是哪一只"(新武器共用)
# ------------------------------------------------------------
# 【执行者】玩家(动手的那个人)
# 【产出】给命中的那一只挂上标签 zx.victim(只挂一只, 取最近)
# 【为什么要有它】advancement 的 conditions 只能**过滤**, 不能把实体传进奖励函数。
#   原版自己在生物身上留了线索: NBT 的 last_hurt_by_player(最近打我的玩家 UUID,
#   4 个 int, 100 tick 后清) + HurtTime(受伤那一刻 10, 下一 tick 9)。
#   两个条件一起用, 就把"这个玩家 5 秒内打过的所有怪"收窄成"刚才这一下"。
#   这套做法是从 equipment/armor/mirage/attack 抄过来的(那边已验证)。
# 【怎么用】
#     function sweetdream:lib/victim
#     execute as @e[tag=zx.victim,limit=1] run <对那只做事>
#     tag @e[tag=zx.victim] remove zx.victim
# 【兜底】少数不记该字段的活体会被"16 格内刚挨打的最近一只"接住, 宁可选错也别没效果。
# 【★ 宏参数绝不要传 zx:data self ★】UUID 四个整数先抄进 zx:work v(本文件已做),
#   再 with storage zx:work v 传给 victim_go —— 直接传 zx:data self 会让宏函数一条都不跑。
# ============================================================

tag @e[tag=zx.victim] remove zx.victim

execute store result storage zx:work v.u0 int 1 run data get entity @s UUID[0]
execute store result storage zx:work v.u1 int 1 run data get entity @s UUID[1]
execute store result storage zx:work v.u2 int 1 run data get entity @s UUID[2]
execute store result storage zx:work v.u3 int 1 run data get entity @s UUID[3]
function sweetdream:lib/victim_go with storage zx:work v

# 兜底: 精确匹配没找到就退回"最近的、刚挨过打的生物"
execute unless entity @e[tag=zx.victim,limit=1] as @e[type=!#sweetdream:no_damage,distance=..16,nbt={HurtTime:10s},sort=nearest,limit=1] run tag @s add zx.victim
execute unless entity @e[tag=zx.victim,limit=1] as @e[type=!#sweetdream:no_damage,distance=..16,nbt={HurtTime:9s},sort=nearest,limit=1] run tag @s add zx.victim
