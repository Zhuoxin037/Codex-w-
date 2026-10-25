# ============================================================
# sweetdream:projectile/ball/tick —— 法球每刻的心跳
# ------------------------------------------------------------
# 【谁调用它】sweetdream:core/tick:
#   execute as @e[tag=zx.ball] at @s run function ... with entity @s data
# 【宏参数】载体 data {uuid,dmg,style,yaw,pitch,u0..u3,hit}
# 【执行者】法球自己(位置就是球的位置)
# 【每刻四件事】
#   ① 撞墙 -> 消失(不掉血)      ② 1.2 格内有生物 -> 命中
#   ③ 前进 0.75 格(有软锁就朝目标拐, 没有就直飞)
#   ④ 画拖尾 + 扣射程
# 【软锁数据从哪来】fire 发射时沿准星挑了一只生物, 把它的 UUID 四个整数
#   写进了 t0..t3。这里就用它拼选择器 —— 所以这个函数必须是宏函数。
#   目标死了 / 本来就没锁到 -> 选择器选不到人, 自动退回"按原朝向直飞"。
# 【为什么"先探再走"】先在"下一步的位置"探方块, 不然球会一头扎进墙里才停下,
#   命中特效就画在墙内部了。
# 【为什么探针半径是 1.0】一步 0.75 格, 半径 1.0 的探针已经连续覆盖整条路径
#   (生物判定箱最窄也有 0.6 宽), 所以不会从怪物身上"穿过去"。
# 【速度】0.75 格/刻 = 15 格/秒, 30 格飞约 2 秒。
# ============================================================

# ① 自己已经在方块里(比如贴墙发射) / 下一步是方块 -> 消失, 不掉血
# ★ 2026-10-21: 出生那一下（zx.ball_dist 还是满程 3000）**不判自己脚下** ★
#   法球是在眼睛前方 1.5 格生成的点，贴墙/贴台阶/贴栅栏发射时，
#   出生点本身就落进不可替换方块 —— 于是第 1 刻就被判"撞墙"，
#   表现是"冒一下风团就没了"，玩家看到的是一发完全空的普攻。
#   现在第 1 刻只检查"下一步"，不因出生点自身所在方块判死；
#   真的撞墙第 2 刻就会停（球只多飞 0.75 格）。
# ★ 2026-10-21 二次修: 这一天里我把它写成过
#     `execute unless score … matches 3000 run unless block …`
#   —— `run` 之后必须跟一条**完整命令**, 而 `unless` 不是命令(它只能作为
#   `execute` 的子参数)。解析直接报 "错误的命令参数 at position 54", 结果是
#   **整个 tick_target 加载失败** ⇒ 法球不推进、不画拖尾, 表现为"法杖特效全没了"。
#   正确写法 = 两个条件挂在**同一条** execute 链上, 中间不要 `run`。
execute unless score @s zx.ball_dist matches 3000 unless block ~ ~ ~ #minecraft:replaceable run return run function sweetdream:projectile/ball/pop with entity @s data
$execute rotated $(yaw) $(pitch) positioned ^ ^ ^0.75 unless block ~ ~ ~ #minecraft:replaceable run return run function sweetdream:projectile/ball/pop with entity @s data

# ② 撞到生物? -> 命中(打伤害 + 消失)
# 【★ 这里必须用"判定箱相交"(dx/dy/dz), 不能用 distance ★】
#   distance 量的是"执行位置 -> 生物**脚底坐标**"的距离, 和判定箱无关。
#   而法球是按眼睛高度飞的、软锁也瞄眼睛 —— 打人偶 / 坚守者这种高个子时
#   球正好悬在它**头顶**, 离"脚"快 3 格, distance=..1.2 永远不成立:
#   现象就是"效果一直在头部萦绕, 却造成不了伤害"。
#   dx/dy/dz 是"生物的判定箱有没有和这个盒子重叠", 体高体长都不影响。
#   做法: 把执行位置挪到"球心 - 0.8", 再开一个 1.6 立方体的盒子。
# ★ 2026-10-21 判定盒 2.2 -> 1.6(玩家: "命中后的作用范围改小一点") ★
#   2.2 立方体(半宽 1.1)意味着球心旁边 1.1 格内的怪全部算命中 —— 两三个怪挨着
#   站的时候一发能连带打中旁边的, 看起来像"没瞄准也打中了"。1.6(半宽 0.8)刚好
#   覆盖一个生物的标准碰撞箱宽(0.6)再加余量, 只打正对着的那一只。
#   ★ 与 hit.mcfunction ①② 的盒子**必须完全一致** —— 否则会出现"判打中了但打不中"
#     或"打中了却没判命中"的错位(两处都改了, 都写成 ~-0.8 / 1.6)。
# 【★ 这两条也要 distance=0.. ★】ball_touch 是"本刻自己在本维度挑出来的", 清理/查询都要锁在
#   当前维度 —— 裸 @e 会跨维度搜索, 理论上可能抓到别的维度里残留的同名标签。
# ★ 2026-10-20: 这里原来写 `distance=0..`(无上界) —— 那是"本维度所有实体逐个算距离",
#   而 zx.ball_touch 只可能标在下面那个 1.6 立方体里, 4 格上界足够且不再全量遍历。
# ★★ 2026-10-21 修 —— 「整个法杖体系都坏了」的真正根因 ★★
#   上面"清理"收窄成 4 格了, 下面"查询"却还留着 `distance=0..`(整个维度)。
#   而 zx.ball_touch 是**计分项**, 打在生物身上会一直留在存档里, 和标签不一样:
#   hit 打完只摘 zx.ball_hit, 从来没清过 zx.ball_touch。
#   ⇒ 只要球命中过一只怪, 那只怪就永久带着 ball_touch=1;
#     之后你在**任何位置**开第二炮, 这一行都会隔着几十格认出它 -> 判"命中" ->
#     hit 里 `kill @s` -> 球在出生点当场消失。
#   表现就是"冒一下风团就没了、一发空普攻", 且**所有法杖同时全废**(共用这条链),
#   第一次命中之后必坏。旧版是 `tag @e[distance=0..]` 全局清, 所以能自愈。
#   ⇒ 查询必须和清理用同一个半径(4 格 = 1.6 立方体的对角线半径 1.39 再加两层余量),
#     并且 hit 里也要补一次清理, 保证分数永不外泄。
scoreboard players reset @e[distance=0..4,scores={zx.ball_touch=1}] zx.ball_touch
execute positioned ~-0.8 ~-0.8 ~-0.8 run scoreboard players set @e[type=!#sweetdream:no_damage,dx=1.6,dy=1.6,dz=1.6,limit=1] zx.ball_touch 1
execute if entity @e[distance=0..4,scores={zx.ball_touch=1},limit=1] run return run function sweetdream:projectile/ball/hit with entity @s data

# ③ 前进
#   · 软锁的目标还活着 -> 朝它拐过去(这就是"好命中"的来源)
#   · 目标死了 / 没锁到 -> 按发射那一刻记下的朝向直线飞
#   两行互斥, 所以每一 tick 只会走其中一条。
# Resolve the exact UUID once. The native @e alive filter is checked without NBT.
scoreboard players set #ball_target_live zx.meta 0
$execute as $(target_uuid) run function sweetdream:projectile/ball/target_alive
$execute if score #ball_target_live zx.meta matches 1 facing entity $(target_uuid) eyes run tp @s ^ ^ ^0.75
$execute unless score #ball_target_live zx.meta matches 1 rotated $(yaw) $(pitch) run tp @s ^ ^ ^0.75

# ④ 拖尾外观(按 style 直接分派 —— 一套 style 一份, 由 _gen_staff_particles.py 维护)
#   ★★ 2026-10-20 卡顿修复: 原来是每个 style 一行 `if data entity @s data{style:"…"}` ★★
#     那 24 行意味着法球飞行期间**每刻**对同一个实体做 24 次 NBT 序列化
#     (2 秒 ≈ 960 次/球, 多球同飞是乘法)。改成宏分派后每刻 0 次。
#     ★ 本函数是 tick 用 `with entity @s data` 调起来的, $(style) 直接可用。
$function sweetdream:projectile/ball/fx_$(style)
# ⑤ 射程耗尽 -> 自己消失
# ★ 2026-10-21 自愈: 射程分数是 fire 里 `scoreboard players set … 3000` 挂上去的,
#   一旦那一步没生效（实体刚 summon 出来的同刻被别处清过 / 选择器没选到），
#   分数是**不存在**的 —— 那么这一行 remove 会先把它建成 -75，
#   下一行 `matches ..0` 立刻成立 ⇒ **法球第 1 刻就 pop**，
#   表现就是"冒一下风团就没了、一发空普攻"。所以缺了就先补满程。
execute unless score @s zx.ball_dist matches -2147483648.. run scoreboard players set @s zx.ball_dist 3000
scoreboard players remove @s zx.ball_dist 75
execute if score @s zx.ball_dist matches ..0 run function sweetdream:projectile/ball/pop with entity @s data
