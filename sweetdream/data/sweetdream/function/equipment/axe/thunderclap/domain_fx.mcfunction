# 威霆领域：field_tick 每秒调用，执行者为术阵 marker，位置已在术阵处。
# 边界由透明祭环纹理描绘；粒子仅点亮四个方向，不再铺满领域内部。
# 保留 6 格半径，普通显示范围；每秒由 30 颗电火花减至 4 颗。
execute rotated 0 0 positioned ^ ^ ^6 run particle minecraft:electric_spark ~ ~0.15 ~ 0.12 0.06 0.12 0.01 1 normal
execute rotated 90 0 positioned ^ ^ ^6 run particle minecraft:electric_spark ~ ~0.15 ~ 0.12 0.06 0.12 0.01 1 normal
execute rotated 180 0 positioned ^ ^ ^6 run particle minecraft:electric_spark ~ ~0.15 ~ 0.12 0.06 0.12 0.01 1 normal
execute rotated 270 0 positioned ^ ^ ^6 run particle minecraft:electric_spark ~ ~0.15 ~ 0.12 0.06 0.12 0.01 1 normal
