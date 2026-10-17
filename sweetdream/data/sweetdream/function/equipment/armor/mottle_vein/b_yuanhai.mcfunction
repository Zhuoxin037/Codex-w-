# ============================================================
# sweetdream:equipment/armor/mottle_vein/b_yuanhai —— 杂纹: 本轮消费过「渊海」
# ------------------------------------------------------------
# 【谁调用它】reward ③   【执行者】玩家
# 【技能原文】"若消耗了「渊海」则使自身 3 格内的全部生物击退 1 格。"
# 【位移手法】包内现役那一招(异彩 eff_3 / 迟庭 lt_end 同款):
#   `at @s facing entity <圆心> feet positioned ^ ^ ^-1 if block ~ ~ ~ #minecraft:replaceable
#    run tp @s ~ ~ ~` —— facing 把朝向定到圆心(玩家), `^-1` 就是"从玩家往外退 1 格";
#   `if block … replaceable` = 文案里"遇到障碍即停"的等价实现(撞墙就不动)。
# 【★ 圆心为什么要打标签 ★】下面要 `as 生物`, 那时 @s 已经不是玩家了, 只能用
#   一个临时标签把玩家反查回来(zx.mv_own, 用完即摘)。
# 【★ distance 从 0.01 起 ★】排除玩家自己站在圆心那一点(玩家不会被"击退")。
# ============================================================

tag @a remove zx.mv_own
tag @s add zx.mv_own
execute as @e[type=!#sweetdream:no_damage,distance=0.01..3] at @s facing entity @a[tag=zx.mv_own,limit=1] feet positioned ^ ^ ^-1 if block ~ ~ ~ #minecraft:replaceable run tp @s ~ ~ ~
tag @a remove zx.mv_own
