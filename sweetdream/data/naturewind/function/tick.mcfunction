# 3 tick 更新一次、16 个相位，一轮 2.4 秒。没有持有者时不推进也不修改物品。
# @a 不受维度限制；只改两只手里确实使用风行模型的物品。
execute unless items entity @a weapon.mainhand minecraft:recovery_compass[minecraft:item_model="naturewind:staff"] unless items entity @a weapon.offhand minecraft:recovery_compass[minecraft:item_model="naturewind:staff"] run return 0
scoreboard players add #clock nw.anim 1
execute if score #clock nw.anim matches 3.. run function naturewind:step
