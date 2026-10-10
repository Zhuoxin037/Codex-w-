# ============================================================
# sweetdream:equipment/armor/mirage/attack —— 幻昼: 攻击生物后铺「白昼梦」
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:equipment/armor/mirage_attack(player_hurt_entity)
# 【执行者】玩家(动手的那个人)
# 【文案上写的】
#   ② 自身攻击生物后有 20% 的概率对其附加「白昼梦」效果
#   ③ 当附带「白昼梦」的生物受到伤害后, 有 20% 的概率时停 1 秒
# 【★ 进度拿不到"被打的到底是谁", 但生物自己记着 ★】
#   advancement 的 conditions 只能**过滤**, 不能把实体传进奖励函数。
#   以前只能靠"16 格内 HurtTime 为 10/9 的最近生物"猜 —— 两个人各打各的、
#   或者旁边正好有另一只刚挨过打的怪, 就会挑错; 16 格外远程命中还会漏选
#   (审查第 4 条)。
#
#   现在用原版自己留下的那条线索: 生物 NBT 里的 **last_hurt_by_player**,
#   也就是"最近一次打我的玩家是谁"(UUID, 4 个 int)。这是原版为了怪报复玩家
#   特意记的, 100 tick(5 秒)后才清 —— 玩家 UUID 是精确值, 不是启发式。
#   再叠一层 HurtTime(受伤那一刻是 10, 下一 tick 是 9), 就把"刚才这一下"
#   从"这个玩家 5 秒内打过的所有怪"里钉死。
#   两个条件都要满足 ⇒ 除非同一个人在两刻内各打了一只不同的怪, 否则不会错选。
#
#   【为什么留着老办法兜底】少数生物可能不记这个字段(比如非 Mob 的活体),
#   兜底让它们行为不变, 而不是彻底不生效 —— 宁可退化成旧行为, 不能没有效果。
# 【为什么不再限制 16 格】有了精确键就不需要"就近猜"了, 顺带修掉
#   "16 格外远程命中漏选"。@e 全维度扫的代价只在"玩家打中东西"时付一次。
# 【AOE 仍然只对一只生效】文案是"对其"(单只), 所以照旧 limit=1 取最近的那只。
# ============================================================

advancement revoke @s only sweetdream:equipment/armor/mirage_attack
# ---- 满蓄力闸(2026-10-10, 全包统一口径) ----
#   平A 没**蓄满力**这一发就不触发本被动。判定与出参见 lib/atk_charge 头部
#   (每刻只算一次 + 玩家级 `@s zx.atk_ok`)。
#   ★ 必须排在 revoke 之后: lib/rearm 契约要求 revoke 是奖励函数第一非注释行。
function sweetdream:lib/atk_charge
execute unless score @s zx.atk_ok matches 1 run return 0

# ① 没穿幻昼就没这事
execute unless items entity @s armor.legs netherite_leggings[custom_data~{zx:["mirage"]}] run return 0

# ② 定位"刚刚被打的那只"
tag @e[tag=zx.mr_t] remove zx.mr_t

# ②.1 拼自己的 UUID —— NBT 里 UUID 是 [I;a,b,c,d] 四个 int, 要和
#      last_hurt_by_player 逐位比对, 所以只能自己拼一个同形状的数组出来。
#      (没有"把 UUID 塞进选择器"的语法, 只能靠宏函数把四个数字拼进命令文本。)
execute store result storage zx:work mr_v.u0 int 1 run data get entity @s UUID[0]
execute store result storage zx:work mr_v.u1 int 1 run data get entity @s UUID[1]
execute store result storage zx:work mr_v.u2 int 1 run data get entity @s UUID[2]
execute store result storage zx:work mr_v.u3 int 1 run data get entity @s UUID[3]
function sweetdream:equipment/armor/mirage/find_victim with storage zx:work mr_v

# ②.2 兜底: 精确匹配没找到(生物没记字段 / 是摔落之类没有"动手的人"的伤害)
#      就退回老办法 —— 最近的、刚挨过打的生物。
execute unless entity @e[tag=zx.mr_t,limit=1] as @e[type=!#sweetdream:no_damage,distance=..16,nbt={HurtTime:10s},sort=nearest,limit=1] run tag @s add zx.mr_t
execute unless entity @e[tag=zx.mr_t,limit=1] as @e[type=!#sweetdream:no_damage,distance=..16,nbt={HurtTime:9s},sort=nearest,limit=1] run tag @s add zx.mr_t
execute unless entity @e[tag=zx.mr_t,limit=1] run return 0

# ③ 两次独立判定(20% 附加白昼梦 + 20% 时停), 随机源见 dream_roll
#    (随机源已经和坐标/节奏脱钩了, 不用再把 tick 拷到 #mr_now 里)
execute as @e[tag=zx.mr_t,limit=1] run function sweetdream:equipment/armor/mirage/dream_roll

tag @e[tag=zx.mr_t] remove zx.mr_t
