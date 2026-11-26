# ============================================================
# fallendream:equipment/bow/feather_sleep/chain —— 眠羽·超限：羽箭不消失，继续追下一个
# ------------------------------------------------------------
# 【执行者】刚刚被这枚羽箭打中的那只生物(fire ⑤.5 用 as/at 送进来)
# 【入参】zx:work fs {uuid, u0..u3, dmg, s2_b_dmg}
# 【文案】"之后被追踪的生物的 8 格内若还有其他生物则箭不会消失并继续追踪其他生物，
#   最多额外追踪 6 个生物。若被额外追踪的生物上附有「白昼梦」则再额外追踪一个生物。"
# 【★ 额度是整发共享的 6 个 ★】记在伪玩家 #fs_budget 上(不是每枚羽箭各 6 个),
#   三枚羽箭的链一起花。花掉一个后, 若新目标带「白昼梦」就补回一个, 但**总额不超
#   初始 6** —— 否则一串带梦的生物能把额度无限续下去(实际会被 zx.fs_seen 挡住,
#   但那已经不是"最多 6 个"了)。
# 【★ 为什么可以自我递归 ★】每层都先扣额度, 额度只减不加(补额也夹在上限内),
#   所以最多 7 层就收; 再加 zx.fs_seen 保证同一只只追一次。
# 【★ 候选必须排除 zx.fs_seen ★】否则链会绕回刚打过的那只, 原地来回踢。
# ============================================================

# ⓪ 摘掉"上一层正在处理"的标记(只摘自己 —— 递归进来时 @s 就是那个标记的主人)
tag @s remove zx.fs_next

# ① 额度用尽就收
execute if score #fs_budget zx.meta matches ..0 run return 0

# ② 从自己 8 格内找"还没追过"的生物
tag @e[tag=zx.fs_n,distance=0..] remove zx.fs_n
execute at @s run tag @e[type=!#fallendream:no_damage,distance=..8,tag=!zx.fs_seen] add zx.fs_n
execute unless entity @e[tag=zx.fs_n,distance=0..,limit=1] run return 0

# ③ 挑最近的一只
execute at @s run tag @e[tag=zx.fs_n,sort=nearest,limit=1] add zx.fs_next
tag @e[tag=zx.fs_n,distance=0..] remove zx.fs_n

# ④ 入名单 -> 花掉一个额度 -> 带「白昼梦」则补一个(总额仍不超上限)
tag @e[tag=zx.fs_next,distance=0..] add zx.fs_seen
scoreboard players remove #fs_budget zx.meta 1
execute as @e[tag=zx.fs_next,distance=0..,limit=1] if entity @s[tag=zx.status.dream] if score #fs_budget zx.meta < #fs_cap zx.meta run scoreboard players add #fs_budget zx.meta 1

# ⑤ 表现: 一片白羽从自己飘出去(方向感靠目标处的落地粒子补)
execute at @s run particle minecraft:item{item:{id:"minecraft:feather",count:1}} ~ ~1 ~ 0.3 0.3 0.3 0.03 4 normal

# ⑥ 打它(与首轮的羽箭同一份伤害 / 同一份缓慢Ⅱ)
execute as @e[tag=zx.fs_next,distance=0..,limit=1] at @s run function fallendream:equipment/bow/feather_sleep/hit

# ⑦ 从它继续往下追(递归; 层数由额度与 zx.fs_seen 兜住)
execute as @e[tag=zx.fs_next,distance=0..,limit=1] at @s run function fallendream:equipment/bow/feather_sleep/chain with storage zx:work fs
