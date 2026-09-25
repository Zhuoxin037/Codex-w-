# ------------------------------------------------------------
# internal/cooldown/start_sec —— 秒级冷却换算
# 【职责】只做一件事: cooldown_seconds x 20 -> #dur(tick)。
# 【千万不要在这里调 start_go】以前这里调了, 结果和 start 里那句
#   "if #dur matches 1.. run start_go" 撞车:
#     ① start 里 #dur = 0 -> 调本函数
#     ② 本函数把 #dur 换成 400 -> 调 start_go(第一次) -> #dur 加上 #now 变成 32467
#     ③ 回到 start, 那句 "matches 1.." 又成立 -> start_go(第二次)
#        -> total 被写成 32467(= #now + 时长), end 又被加一次 #now
#   tick 冷却不走这条路径, 所以只有"秒级冷却"会中招 —— 流光正是秒级。
#   现在统一由 start 在一处进入 start_go, 两边不会重复。
# ------------------------------------------------------------
execute store result score #dur manacore.math run data get storage manacore:work a.cooldown_seconds 20
