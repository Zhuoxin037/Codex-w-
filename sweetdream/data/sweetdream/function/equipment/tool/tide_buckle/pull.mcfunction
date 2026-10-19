# 回潮扣：消费后使用消费前的身份快照，不重查已经失效的原状态选择器。
# 执行者 = 消耗者。把玩家 UUID 单独保存，切换圆心上下文后仍由本人付费。
execute unless items entity @s weapon.offhand *[minecraft:custom_data~{zx:["tide_buckle"]}] run return 0
execute unless entity @e[tag=zx.tb_source,distance=0..] run return 0
data modify storage zx:work tb set value {u0:0,u1:0,u2:0,u3:0}
data modify storage zx:work tb.u0 set from entity @s UUID[0]
data modify storage zx:work tb.u1 set from entity @s UUID[1]
data modify storage zx:work tb.u2 set from entity @s UUID[2]
data modify storage zx:work tb.u3 set from entity @s UUID[3]
execute as @e[tag=zx.tb_source,distance=0..] at @s run function sweetdream:equipment/tool/tide_buckle/pull_center with storage zx:work tb
