# ============================================================
# sweetdream:equipment/axe/anchor/ray —— 准星射线的一步(递归)
# ------------------------------------------------------------
# 【执行者】施法者(玩家); 【位置/朝向】当前探针所在点(入口用 anchored eyes 起头)
# 【每一步做四件事】
#   ① 步数 +1, 超过 20 步(0.5×20 = 10 格)收工 —— 射程上限
#   ② 这一步的 1.4 判定箱里有可伤害生物 -> 挂 zx.an_tgt 并停
#      (用 dx/dy/dz **判定箱相交**, 贴脸/高个子都吃得到; 不用 distance —— 同 cold_crow/step)
#   ③ 撞到非可替换方块 -> 停(锚/视线被挡住)
#   ④ 沿同一朝向再走 0.5 格, 递归(朝向是继承的, 所以这一路是直线)
# 【为什么每步 0.5 格】0.5 × 20 = 10 格正好是文案射程; 步距远小于生物碰撞箱,
#   不会从生物身上"穿过去"。
# ============================================================

scoreboard players add #an_st zx.meta 1
execute if score #an_st zx.meta matches 21.. run return 0

# ② 命中判定: 以这一步为中心开一个 1.4 的盒子
execute positioned ~-0.7 ~-0.7 ~-0.7 run tag @e[type=!#sweetdream:no_damage,dx=1.4,dy=1.4,dz=1.4,limit=1] add zx.an_tgt
execute if entity @e[tag=zx.an_tgt,distance=0..,limit=1] run return 0

# ③ 撞墙就停
execute unless block ~ ~ ~ #minecraft:replaceable run return 0

# ④ 继续往前 0.5 格
execute positioned ^ ^ ^0.5 run function sweetdream:equipment/axe/anchor/ray
