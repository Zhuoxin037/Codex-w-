# ============================================================
# sweetdream:equipment/armor/styx_walk/sea_pick_model —— 随机挑一个暗海形态
# ------------------------------------------------------------
# 【谁调用它】sea_spawn / sea_spawn_small —— 在 sea_make 之前, 且**紧挨着**
# 【怎么随机】`random value 1..3` 抽 1~3, 用 `execute store result` 接住。
#   假玩家 #sea_pick 借 zx.meta 板(通用暂存板, debug/freeze_one 也是这么用的),
#   一次一抽、用完即弃 —— 不新增计分项。
# 【写进哪】storage zx:work sea_mk.model —— sea_make 就是拿这个当宏参数的。
#   ★ 顺序硬要求: 先写 model、再调 sea_make, 中间别插别的命令。
# 【三形态】(资源包素材由 .workbuddy/_gen_sea.py 生成)
#   ★ 都是**自然湖泊**式的缓岸轮廓 —— 无尖角 / 无挖洞 / 无缺口
#     (控制点半径区间收窄到 0.79~1.00, 高频抖动 ≤0.022, 彻底不用 bite/holes)
#   sweetdream:sea_a = 缓湾湖 —— 5 个缓湾控制点 + 长轴略偏东西 + 旋涡暗纹
#   sweetdream:sea_b = 长湖   —— 7 个弱凸起 + 明显被拉长(南北向) + 无旋涡
#   sweetdream:sea_c = 半月湖 —— 8 个缓凸起 + 一侧宽缓内湾(半月感) + 旋涡暗纹
#   ★ 三形态只是贴图/轮廓不同, 直径一致 ⇒ 动画轨道(sea_in6/out6/in4/out4)共用。
# ============================================================

execute store result score #sea_pick zx.meta run random value 1..3
data modify storage zx:work sea_mk.model set value "sweetdream:sea_a"
execute if score #sea_pick zx.meta matches 2 run data modify storage zx:work sea_mk.model set value "sweetdream:sea_b"
execute if score #sea_pick zx.meta matches 3 run data modify storage zx:work sea_mk.model set value "sweetdream:sea_c"
