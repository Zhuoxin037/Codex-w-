# ============================================================
# sweetdream:equipment/sword/gousi/ol_pull_go —— 超限·钩丝 每 5 刻的入口(执行者 = 玩家)
# ------------------------------------------------------------
# 【谁调它】core/tick: `#gs_ph == 0` 且 zx.gs_st = 1.. 的玩家 -> gousi/pull_go
#   -> pull_go 顶部按 zx.gs3 分流到这里。
# 【为什么还要转一次】ol_pull 是宏函数(要 $(own) 拼 tag), storage 参数得现搭。
# 【★ 只覆盖 own 一个键 ★】uu / u0..u3 是施法那一刻拍好的(见 ol_cast ⑥),
#   这里 `set value {own:0}` 整段重写会把它们抹掉, 于是"拉到位那一发"失去
#   魔力基数与归属(伤害静默变成 1)。
# ============================================================
scoreboard players operation #gs_o zx.meta = @s zx.gs_own
execute store result storage zx:work gs3.own int 1 run scoreboard players get #gs_o zx.meta
execute at @s run function sweetdream:equipment/sword/gousi/ol_pull with storage zx:work gs3
