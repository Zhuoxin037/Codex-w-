# ============================================================
# sweetdream:equipment/hengdao/dash_tick —— 每刻推进一步(突进)
# ------------------------------------------------------------
# 【谁调用它】sweetdream:core/tick:
#   execute as @a[scores={zx.dash=1..}] at @s run function ...
# 【还剩几步存在哪】就是玩家自己在 zx.dash 上的分数。
#   用计分项而不是 storage: 它天然"每个玩家各一份", 不用按 UUID 拼路径,
#   所以这一整套完全不需要宏函数 —— 少一层就少一类坑。
# 【一步多大 / 一共多远】0.25 格 x 12 步 = 3 格。
#   要改距离: cast 里的 12 和这里的 0.25 两个都要动。
# 【怎么停】
#   方块挡路: 走完这一步后, 脚和上半身那两格不能穿过去(#minecraft:replaceable 之外)
#   生物挡路: 走完这一步后, 0.45 格内有实体(no_damage 名单里含玩家, 所以自己不算)
#   撞到就把分数清 0 —— 这一 tick 立刻结算, 下一 tick 选择器也不再选他。
# 【为什么探针放 0.25 而不是 1】一步就走 0.25, 探针也该看"走完这一步之后人在哪一格",
#   放 1 会提前一整格停下。
# ============================================================

# 【rotated ~ 0 是干嘛的 —— 这个坑踩过一次, 别删】
#   ^ 这种局部坐标是"带着俯仰角"的: 你视角稍微往下压一点, ^ ^ ^0.25 就会
#   往斜下方算, 探针落到脚前的草方块/地面那一格里 -> 被判成"撞墙" -> 突进
#   直接停在第 0 步, 表现就是"完全不突进"。
#   rotated ~ 0 = 朝向保留, 俯仰角强制归零, 于是 ^ ^ ^ 只沿水平方向走。
#   玩家自己看的视角不受影响(这里只改"计算坐标时用的朝向")。

# 挡路判定: 把探针挪到"走完这一步"的位置, 再检查那一格
execute rotated ~ 0 positioned ^ ^ ^0.25 unless block ~ ~ ~ #minecraft:replaceable run scoreboard players set @s zx.dash 0
execute rotated ~ 0 positioned ^ ^ ^0.25 unless block ~ ~1 ~ #minecraft:replaceable run scoreboard players set @s zx.dash 0
execute rotated ~ 0 positioned ^ ^ ^0.25 if entity @e[type=!#sweetdream:no_damage,distance=..0.45] run scoreboard players set @s zx.dash 0

# 还能走就挪一点, 然后把剩余步数减 1
execute if score @s zx.dash matches 1.. rotated ~ 0 run tp @s ^ ^ ^0.25
execute if score @s zx.dash matches 1.. run scoreboard players remove @s zx.dash 1

# 走完了 / 被挡住了 -> 落点结算
execute if score @s zx.dash matches ..0 run function sweetdream:equipment/hengdao/dash_end
