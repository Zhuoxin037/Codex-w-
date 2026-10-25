# ============================================================
# sweetdream:equipment/sword/gousi/pull_go —— 每 5 刻的入口（执行者 = 玩家）
# ------------------------------------------------------------
# 【谁调】core/tick：`#now % 5 == 0` 且 zx.gs_st = 1.. 的玩家
# 【为什么还要转一次】pull 是宏函数，需要一个 storage 参数；这里把
#   zx.gs_own（玩家身上的 UUID[0]）搬进 zx:work gs 再调。
# ============================================================
# 【超限分流(2026-10-23 批 K3)】敲过超限石的钩丝是"三目标 × 0.8 格/步"的另一套闭环
#   (ol_pull_go)。zx.gs3 是施法那一刻 ol_cast 打上的标记, 收尾时由 ol_done 清零。
#   放在最前面: 下面那几行是原版单目标路径, 一个字都不该被超限改动。
execute if score @s zx.gs3 matches 1 run return run function sweetdream:equipment/sword/gousi/ol_pull_go

scoreboard players operation #gs_o zx.meta = @s zx.gs_own
data modify storage zx:work gs set value {own:0}
execute store result storage zx:work gs.own int 1 run scoreboard players get #gs_o zx.meta
execute at @s run function sweetdream:equipment/sword/gousi/pull with storage zx:work gs
