# ============================================================
# sweetdream:equipment/sword/blood_loss/ray —— 准星射线的一步(递归)
# ------------------------------------------------------------
# 【执行者】施法者(玩家); 【位置/朝向】当前探针所在点(入口用 anchored eyes 起头)
# 【目标】文案"准星前方 5 格内一个生物" —— 0.5×10 = 5 格, 所以步数上限 11。
# 【每一步做四件事】
#   ① 步数 +1, 超过 10 步(已走到 5 格)收工
#   ② 这一步的 1.4 判定箱里有可伤害生物 -> 挂 zx.bld_tgt 并停(只取最近一只)
#      (用 dx/dy/dz **判定箱相交**; 不用 distance —— 它量的是到**脚底**的距离, 坑 157)
#   ③ 撞到非可替换方块 -> 停(视线被挡住)。先判生物再判墙: 站在墙前贴脸的怪也打得中。
#   ④ 沿同一朝向再走 0.5 格, 递归(朝向继承, 所以这一路是直线)
# 【★ 与沉锚 anchor/ray 同构 ★】只改了射程(20 步 -> 10 步)与标签名。
#   步距 0.5 远小于生物碰撞箱, 不会从生物身上"穿过去"。
# ============================================================

scoreboard players add #bld_st zx.meta 1
execute if score #bld_st zx.meta matches 11.. run return 0

# ② 命中判定: 以这一步为中心开一个 1.4 的盒子
execute positioned ~-0.7 ~-0.7 ~-0.7 run tag @e[type=!#sweetdream:no_damage,dx=1.4,dy=1.4,dz=1.4,sort=nearest,limit=1] add zx.bld_tgt
execute if entity @e[tag=zx.bld_tgt,distance=0..,limit=1] run return 0

# ③ 撞墙就停
execute unless block ~ ~ ~ #minecraft:replaceable run return 0

# ④ 继续往前 0.5 格
execute positioned ^ ^ ^0.5 run function sweetdream:equipment/sword/blood_loss/ray
