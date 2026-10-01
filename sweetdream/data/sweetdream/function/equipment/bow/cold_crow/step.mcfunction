# ============================================================
# sweetdream:equipment/bow/cold_crow/step —— 探针的一步(宏 {uuid,tier,dmg,u0..u3})
# ------------------------------------------------------------
# 【执行者】射手(玩家); 位置/朝向 = 当前探针所在的那一点
# 【每一步做三件事】
#   ① 计数 +1, 超过 60 步(30 格)收工 —— 射程上限
#   ② 这一步的位置上有没有"可伤害生物"的判定箱 -> 有就是命中, 交给 hit_at 结算并停
#      (用 dx/dy/dz 判定箱相交, 高个子/人偶也吃得到; 不用 distance)
#   ③ 撞到挡路的方块 -> 停(箭会被挡住)
# 【怎么往前走】positioned ^ ^ ^0.5 = 沿"当前朝向"再挪 0.5 格, 然后把函数以新位置递归调一次
#   (朝向是继承的, 所以这一路是直线)。
# ============================================================

scoreboard players add #cc_step zx.meta 1
execute if score #cc_step zx.meta matches 61.. run return 0

# ② 命中判定: 以这一步为中心开一个 1.4 的盒子
tag @e[tag=zx.cc_touch] remove zx.cc_touch
execute positioned ~-0.7 ~-0.7 ~-0.7 run tag @e[type=!#sweetdream:no_damage,dx=1.4,dy=1.4,dz=1.4,limit=1] add zx.cc_touch
execute if entity @e[tag=zx.cc_touch,limit=1] run return run function sweetdream:equipment/bow/cold_crow/hit_at with storage zx:work cc

# ③ 撞墙就停(和法球用的是同一套"能不能穿过"判定)
execute unless block ~ ~ ~ #minecraft:replaceable run return 0

# 继续往前 0.5 格
execute positioned ^ ^ ^0.5 run function sweetdream:equipment/bow/cold_crow/step with storage zx:work cc
