# 两套节拍，互不相干：
#   · 待机枝冠：3 tick 一个相位、16 个相位，一轮 2.4 秒。没有持有者时不推进也不修改物品。
#   · 释放动画：每 tick 一帧、共 26 帧，只在施法之后那 1.3 秒里跑。
# @a 不受维度限制；只改两只手里确实使用风行模型的物品。
#
# ⚠️ 释放动画这一行必须放在下面那句 return 0 **之前**：
#   那句 return 是"场上没人拿法杖就整个函数退出"的性能优化 ——
#   但施法到一半把法杖丢掉的玩家，仍然需要 cast_tick 把计数走完、把 tag 摘掉，
#   否则 nw.casting 会永远挂在他身上。放在 return 之后就会被一起吞掉。
execute as @a[tag=nw.casting] run function naturewind:cast_tick

execute unless items entity @a weapon.mainhand minecraft:recovery_compass[minecraft:item_model="naturewind:staff"] unless items entity @a weapon.offhand minecraft:recovery_compass[minecraft:item_model="naturewind:staff"] run return 0
scoreboard players add #clock nw.anim 1
execute if score #clock nw.anim matches 3.. run function naturewind:step
