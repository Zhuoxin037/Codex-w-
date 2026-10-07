# ============================================================
# sweetdream:equipment/armor/styx_walk/sea_area —— 圈出这片暗海里的活体
# ------------------------------------------------------------
# 【宏参数】zx:work sea {r} —— 半径(主片 3 / 次级片 2)
#   调用处: function .../sea_area with entity @s data.zx.sea(执行位置 = 暗海中心)
# 【为什么半径要宏化】主片 3 格、次级片 2 格 —— distance 是命令文本的一部分,
#   只能靠宏把 r 拼进去, 否则得写两份一模一样的函数。
# 【两个过滤条件】
#   · type=!#sweetdream:no_damage —— 排掉玩家 / marker / 掉落物 / 各类 display
#     (这个标签列全了全部非活体, 所以**不需要**再写 distance=0.1.. 那种技巧)
#   · nbt=!{Health:0.0f} —— 排掉"已死但还没消失"的尸体(死亡后约 20 tick 仍是实体)
# 【limit 不设】一片暗海里的所有活体都要吃伤害/效果, 所以是全选。
# ============================================================

$tag @e[type=!#sweetdream:no_damage,distance=..$(r),nbt=!{Health:0.0f}] add zx.sea_hit
