# ============================================================
# sweetdream:debug/tg_router —— /trigger 的总路由(每刻, 由 core/tick 调)
# ------------------------------------------------------------
# 【玩家怎么用】在聊天栏敲:
#     /trigger zx.dbg_menu     打开可点击的调试菜单(推荐从这里进)
#     /trigger zx.dbg_give     发一套潜影盒(至今全部的东西: 装备 + 强化石)
#     /trigger zx.dbg_stats    查看自己的全部数值
#     /trigger zx.dbg_worn     身上 6 个槽位穿了什么
#     /trigger zx.dbg_diff     和上次快照比, 变了什么
#     /trigger zx.dbg_raw      原始面板数据(全部字段)
#     /trigger zx.dbg_cd       立刻结束主手武器的技能冷却
#     /trigger zx.dbg_mana     回满魔力(等价 +1000, 然后被上限夹住)
#
# 【★ 为什么用 trigger 型计分项 ★】
#   trigger 是原版专门给"没有 OP 权限的玩家也能自己触发一条命令"开的口子:
#   玩家敲 /trigger <名> 就能把"属于自己"的那一格设成 1, 而 /scoreboard 是
#   管理员命令。想做"玩家自助菜单"只能用这个。
#
# 【★ 用掉一次就会被原版关掉 ★】
#   /trigger 成功之后, 原版会立刻把这一项对该玩家 disable + 分数归 0。
#   不重新 enable 的话每人只能按一次 —— 重新打开的活儿在 debug/second 里。
#
# 【开销】平时所有人的分数都是 0 / 不存在, 八个选择器全空, 一条命令都不会
#   往下走。只有刚按过的那一个人会进。
#
# 【★ 加新入口要做四件事 ★】
#   ① core/load 里建 trigger 计分项  ② 这个文件加一行路由
#   ③ debug/second 加一行 enable     ④ lib/reg/build 的 tg 表加一条(菜单才看得见)
# ============================================================

execute as @a[scores={zx.dbg_menu=1..}] run function sweetdream:debug/tg_menu
execute as @a[scores={zx.dbg_stats=1..}] run function sweetdream:debug/tg_stats
execute as @a[scores={zx.dbg_worn=1..}] run function sweetdream:debug/tg_worn
execute as @a[scores={zx.dbg_diff=1..}] run function sweetdream:debug/tg_diff
execute as @a[scores={zx.dbg_raw=1..}] run function sweetdream:debug/tg_raw
execute as @a[scores={zx.dbg_cd=1..}] run function sweetdream:debug/tg_cd
execute as @a[scores={zx.dbg_mana=1..}] run function sweetdream:debug/tg_mana
execute as @a[scores={zx.dbg_give=1..}] run function sweetdream:debug/tg_give
