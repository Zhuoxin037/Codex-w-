# ============================================================
# sweetdream:equipment/staff/late_court/ray —— 准星射线的一步(递归)
# ------------------------------------------------------------
# 【执行者】施法者(玩家); 【位置/朝向】当前探针所在处(入口用 anchored eyes 起头)
# 【每一步做三件事】
#   ① 步数 +1, 超过 30 步(0.5 × 30 = 15 格)就收工 —— 射程上限, 就地落领域
#   ② 当前探针处撞到非可替换方块 -> **退回 0.5 格**落领域(停在方块前, 不打断视线)
#   ③ 是空气 -> 沿同一朝向再走 0.5 格, 递归(朝向继承, 所以这一路是直线)
# 【★ 为什么每步 0.5 格】0.5 × 30 = 15 格; 步距远小于一格, 不会"跳过"一格墙。
# 【★ 为什么不停在生物身上(和 anchor/ray 的关键区别) ★】
#   沉锚(axe/anchor/ray)要的是"准星**上的那个目标**", 所以撞到生物就停;
#   迟庭要的是"准星**处**" —— 玩家瞄的那个位置。视线里站着一只怪不该把领域拦在它身上,
#   所以这里**只判方块、不判生物**。
# 【★ 只用 ~ 相对坐标判方块 ★】`execute unless block ~ ~ ~ <谓词>` 是 anchor/ray 的现役写法;
#   本函数不引入 `if block ^ ^ ^N` 这类**包内没有先例**的写法(坑 151)。
# ============================================================

scoreboard players add #ltc_st zx.meta 1

# ① 到射程上限 -> 就地落领域并收工
execute if score #ltc_st zx.meta matches 31.. run function sweetdream:equipment/staff/late_court/place with storage zx:work ltf
execute if score #ltc_st zx.meta matches 31.. run return 0

# ② 这一步撞墙 -> 退 0.5 格落领域(退回去那格一定是刚才走过的空气)
execute unless block ~ ~ ~ #minecraft:replaceable positioned ^ ^ ^-0.5 run function sweetdream:equipment/staff/late_court/place with storage zx:work ltf

# ③ 这一步是空气 -> 继续往前 0.5 格
execute if block ~ ~ ~ #minecraft:replaceable positioned ^ ^ ^0.5 run function sweetdream:equipment/staff/late_court/ray
