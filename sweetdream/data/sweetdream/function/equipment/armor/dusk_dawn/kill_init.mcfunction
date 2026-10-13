# ============================================================
# sweetdream:equipment/armor/dusk_dawn/kill_init —— 同一次击杀只清一次账
# ------------------------------------------------------------
# 【为什么需要它】"击杀 200"和"带标签再 +100×X"是**两组进度**
#   (dusk_dawn_kill 一条 + dusk_dawn_kill_mark_<tag> 五条),
#   奖励函数的**执行顺序不可控**。所以让它们都先调这里:
#   用"当前时刻"判断是不是同一次击杀 —— 第一次调进来才把账本清零, 后面直接 return。
# 【为什么用 #now 当代替"击杀编号"】同一 tick 内所有奖励函数都会跑完,
#   所以"时刻相同"就等于"同一次击杀", 不用额外维护计数器。
# 【★ dd_n 是什么(2026-10-12 坑 138)★】"本刻进来了几次" —— 由 kill_mark 自增。
#   因为 5 条标签进度**各自独立触发**, 死者身上有几个通用标签就会进来几次,
#   于是 dd_n 天然等于 X = 100×X 里那个 X。它必须**跟着账本一起**在这里归零:
#   忘了归零 ⇒ 第二次击杀时 dd_n 接着上次的数往上加 ⇒ 基础版"只加一次"的判据
#   (`dd_n matches 1`)永远不成立 ⇒ 数值静默偏低。
# ============================================================

scoreboard players add @s zx.dd_know 0
execute if score @s zx.dd_know = #now manacore.meta run return 0
scoreboard players set @s zx.dd_t1 0
scoreboard players set @s zx.dd_t2 0
scoreboard players set @s zx.dd_n 0
scoreboard players operation @s zx.dd_know = #now manacore.meta
