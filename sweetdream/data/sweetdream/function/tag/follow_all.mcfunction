# 原版三个维度各执行一次，不能依赖 tick 默认所在的主世界。
execute in minecraft:overworld run function sweetdream:tag/follow_dimension
execute in minecraft:the_nether run function sweetdream:tag/follow_dimension
execute in minecraft:the_end run function sweetdream:tag/follow_dimension
