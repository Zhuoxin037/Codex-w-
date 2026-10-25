# ============================================================
# sweetdream:equipment/sword/gousi/ol_timeout —— 超限·钩丝 步数用完(宏)
# ------------------------------------------------------------
# 【执行者】玩家
# 【宏参数】zx:work gs3 {own}
# 【做什么】把还挂着 zx.gs3_<own> 的全部按"没拉到"结算(×0.08 + 一次加成)。
# 【★ 为什么必须先给施法者挂 zx.gs3_src ★】ol_miss 里要换回玩家去写加成;
#   这一步由 ol_pull 在步数判定**之前**就已经挂好了标签, 这里不能重复挂/摘
#   (摘了 ol_pull 末尾那一行就白写了, 但也不会出错 —— 只是保持"谁挂谁摘"的规矩)。
# ============================================================
$execute as @e[tag=zx.gs3_$(own),limit=3] at @s run function sweetdream:equipment/sword/gousi/ol_miss with storage zx:work gs3
