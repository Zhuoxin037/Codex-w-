# ============================================================
# sweetdream:equipment/axe/dream_reader/pet_tick —— “入梦体”每刻推进(执行者 = 入梦体)
# ------------------------------------------------------------
# 【谁调用它】core/tick(三维度 × 两遍: 先"已绑定目标"的, 再"未绑定"的; 见 core/tick)
# 【它做什么】
#   ① 安全寿命(30 秒)到 -> 自毁
#   ② 离**施法者** 10 格(超限 **18** 格) -> 自毁(反查施法者, 见 lib/find_by)
#   ②' 超限: **施法者 12 格内已经没有"未被本次打过"的目标** -> 自毁(见 pet_scan)
#   ③ 把自己的目标 uuid 读进 storage(没目标时全 0, 不会走 ④ 的宏分支)
#   ④ 已绑定 -> 调 pet_follow(宏, 按 uuid 精确追"我那一只");
#      未绑定 -> 认领"离它最近的、还没被占的"生物, 并把它的 UUID **抄死在自己身上**
# 【★★★ 2026-10-08 修 bug: "不同入梦体不会追踪同一个目标"没做到 ★★★】
#   老实现的错在哪:
#     认领时给目标打的是**通用**标记 zx.dr_claim; 而靠近那一步写的是
#       `facing entity @e[tag=zx.dr_claim,distance=0..24,sort=nearest,limit=1]`
#     —— 只要求值时有**任何一只**带 claim, 所有入梦体都会朝"离自己最近的那只 claim"飞。
#     于是目标只有一只时, 3 个入梦体全追同一只(玩家实测: "明明写了不会追同一个, 事实还是会")。
#   新实现(三件事一起改):
#     ① 认领成功时, 把**目标的 UUID** 抄进入梦体自己的 `data.zx.tg`, 之后**绑死不再改**;
#     ② ④ 改为宏(pet_follow)按 uuid 反查"我那一只" —— 不再看全局 claim;
#     ③ zx.dr_claim 降级为"同一刻的占位标记", 且改由**已绑定的入梦体每刻重建**
#        (core/tick: 每刻先清 -> 已绑定的先跑重建占位 -> 未绑定的后跑认领, 顺序锁死)。
#     目标不够时(比如只有 1 只、却召了 3 个): 第一个追它, 其余两个认领不到
#     => zx.dr_has 不打、原地悬停, **不会**一起扑上去。
# 【★ 所有 @e 都带位置参数 ★】本函数挂在"每维度各跑一次"的链上(core/tick 的 execute in <维>),
#   裸 @e 会跨维度重复处理 —— 每行都写 distance=...(顺带锁维度)。
# ============================================================

# ① 安全寿命
scoreboard players remove @s zx.dr_life 1
execute if score @s zx.dr_life matches ..0 run return run kill @s

# ② 离施法者 10 格(超限 18 格) -> 自毁
data modify storage zx:work fb.u0 set from entity @s data.zx.u[0]
data modify storage zx:work fb.u1 set from entity @s data.zx.u[1]
data modify storage zx:work fb.u2 set from entity @s data.zx.u[2]
data modify storage zx:work fb.u3 set from entity @s data.zx.u[3]
function sweetdream:lib/find_by with storage zx:work fb
execute unless entity @a[tag=zx.mc_by,limit=1] run return run kill @s
execute if entity @s[tag=zx.dr_ol] unless entity @a[tag=zx.mc_by,distance=0..18,limit=1] run return run kill @s
execute unless entity @s[tag=zx.dr_ol] unless entity @a[tag=zx.mc_by,distance=0..10,limit=1] run return run kill @s

# ②' 超限: 施法者 12 格内已经没有"未被本次打过"的目标 -> 自毁
#   ★ "未攻击过的目标"的名单是**本次 3 只共享**的 tag `zx.dr_done`(用户 2026-10-10 定稿;
#     pet_hit 打完一只就给它盖上, pet_tick ④b 认领时跳过)。
#   ★ "自身12格"的"自身" = **施法者**(同 ② 那句"离自身18格", 用户 2026-10-07 起就这个口径)。
#   ★ 要在 ② 末尾 `tag @a remove zx.mc_by` **之前**跑 —— pet_scan 要用这个标记找施法者。
execute if entity @s[tag=zx.dr_ol] run function sweetdream:equipment/axe/dream_reader/pet_scan
execute if entity @s[tag=zx.dr_fin] run return run kill @s
tag @s remove zx.dr_fin
tag @a remove zx.mc_by

# ③ 把"我绑的那只"的 uuid 读进 storage 宏参数(未绑定时 4 个值都是 0)
data modify storage zx:work fg set value {u0:0,u1:0,u2:0,u3:0}
execute store result storage zx:work fg.u0 int 1 run data get entity @s data.zx.tg[0]
execute store result storage zx:work fg.u1 int 1 run data get entity @s data.zx.tg[1]
execute store result storage zx:work fg.u2 int 1 run data get entity @s data.zx.tg[2]
execute store result storage zx:work fg.u3 int 1 run data get entity @s data.zx.tg[3]

# ④a 已绑定: 精确追"我那一只"(宏; pet_follow 里顺带重建占位标记)
execute if entity @s[tag=zx.dr_has] run function sweetdream:equipment/axe/dream_reader/pet_follow with storage zx:work fg

# ④b 未绑定: 认领一只并绑死
#   ★ pet_bind 的执行者是**目标**(在它上下文里把自己的 UUID 写进 storage bind);
#     回到这里再把 bind 抄进"我"的 data.zx.tg。pet_tick 是逐个跑的, 不会串槽。
data remove storage zx:work bind
#   ★ `tag=!zx.dr_done` = 跳过"本次已经被(任何一只)入梦体打过"的目标 —— 超限时靠它
#     实现"打完换下一个"; 基础版每只只打一次, 带上它也只是更保险(同一只不会被两只抢)。
execute unless entity @s[tag=zx.dr_has] at @s as @e[type=!#sweetdream:no_damage,tag=!zx.dr_claim,tag=!zx.dr_done,distance=0..24,sort=nearest,limit=1] run function sweetdream:equipment/axe/dream_reader/pet_bind
execute unless entity @s[tag=zx.dr_has] if data storage zx:work bind run data modify entity @s data.zx.tg set from storage zx:work bind
execute unless entity @s[tag=zx.dr_has] if data storage zx:work bind run tag @s add zx.dr_has
data remove storage zx:work bind

# ⑤ 表现: 一路暖白金辉光（「白昼梦」调性，2026-10-08 由 minecraft:soul 改）
particle minecraft:dust{color:[1.0,0.95,0.76],scale:1.0} ~ ~ ~ 0.15 0.15 0.15 0.01 2 normal
