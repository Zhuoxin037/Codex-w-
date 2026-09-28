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
execute unless block ~ ~ ~ #minecraft:replaceable run return run function sweetdream:projectile/ball/pop
$execute rotated $(yaw) $(pitch) positioned ^ ^ ^0.75 unless block ~ ~ ~ #minecraft:replaceable run return run function sweetdream:projectile/ball/pop

# ② 撞到生物? -> 命中(打伤害 + 消失)
# 【★ 这里必须用"判定箱相交"(dx/dy/dz), 不能用 distance ★】
#   distance 量的是"执行位置 -> 生物**脚底坐标**"的距离, 和判定箱无关。
#   而法球是按眼睛高度飞的、软锁也瞄眼睛 —— 打人偶 / 坚守者这种高个子时
#   球正好悬在它**头顶**, 离"脚"快 3 格, distance=..1.2 永远不成立:
#   现象就是"效果一直在头部萦绕, 却造成不了伤害"。
#   dx/dy/dz 是"生物的判定箱有没有和这个盒子重叠", 体高体长都不影响。
#   做法: 把执行位置挪到"球心 - 1.1", 再开一个 2.2 立方体的盒子。
tag @e[tag=zx.ball_touch] remove zx.ball_touch
execute positioned ~-1.1 ~-1.1 ~-1.1 run tag @e[type=!#sweetdream:no_damage,dx=2.2,dy=2.2,dz=2.2,limit=1] add zx.ball_touch
execute if entity @e[tag=zx.ball_touch,limit=1] run return run function sweetdream:projectile/ball/hit with entity @s data

# ③ 前进
#   · 软锁的目标还活着 -> 朝它拐过去(这就是"好命中"的来源)
#   · 目标死了 / 没锁到 -> 按发射那一刻记下的朝向直线飞
#   两行互斥, 所以每一 tick 只会走其中一条。
$execute if entity @e[nbt={UUID:[I;$(t0),$(t1),$(t2),$(t3)]},limit=1] facing entity @e[nbt={UUID:[I;$(t0),$(t1),$(t2),$(t3)]},limit=1] eyes run tp @s ^ ^ ^0.75
$execute unless entity @e[nbt={UUID:[I;$(t0),$(t1),$(t2),$(t3)]},limit=1] rotated $(yaw) $(pitch) run tp @s ^ ^ ^0.75

# ④ 拖尾外观(按 style 分工; 现在只有 wind 一种)
execute if data entity @s data{style:"wind"} run function sweetdream:projectile/ball/fx_wind

# ⑤ 射程耗尽 -> 自己消失
scoreboard players remove @s zx.ball_dist 75
execute if score @s zx.ball_dist matches ..0 run function sweetdream:projectile/ball/pop
