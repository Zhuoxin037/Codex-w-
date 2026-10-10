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
#     /trigger zx.dbg_fadd     自己的术阵 +1(永久, 用 -1 摘)
#     /trigger zx.dbg_fdel     自己的术阵 -1(摘编号最大的那个非空槽)
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
# 【开销】平时所有人的分数都是 0 / 不存在, 十个选择器全空, 一条命令都不会
#   往下走。只有刚按过的那一个人会进。
#
# 【★ 加新入口要做四件事 ★】
#   ① core/load 里建 trigger 计分项  ② 这个文件加一行路由
#   ③ debug/second 加一行 enable(管理类要加到 debug/enable_admin)
#   ④ lib/reg/build 的 tg 表加一条(菜单才看得见)
#
# 【C01 · 管理类入口的权限】发布服务器上不该让普通玩家发物/改数值。
#   本文件把路由分成两段: 上段是只读入口(人人可用), 下段(③)是管理类,
#   只有在"开发模式"或"带 zx.admin 标签"时才路由。默认值与开关见 core/load 的 C01 段。
# ============================================================

execute as @a[scores={zx.dbg_menu=1..}] run function sweetdream:debug/tg_menu
execute as @a[scores={zx.dbg_stats=1..}] run function sweetdream:debug/tg_stats
execute as @a[scores={zx.dbg_worn=1..}] run function sweetdream:debug/tg_worn
execute as @a[scores={zx.dbg_diff=1..}] run function sweetdream:debug/tg_diff
execute as @a[scores={zx.dbg_raw=1..}] run function sweetdream:debug/tg_raw

# ---- ③ 管理类入口(C01: 改背包/数值/世界, 按权限路由) ----
#   开发模式(#dev zx.meta = 1) → 谁按都行; 发布模式 → 只认 zx.admin 标签。
#   ★ 两条只会有其中一条真正执行: 上面那条跑完会把分数归 0(见各 tg_* 头注释),
#     于是下面这条的 scores 匹配就不再命中; 反之 #dev=0 时上面那条整个被 if 挡掉。
#   ★ 光看 enable 其实已经够(没 enable 玩家敲 /trigger 会被原版拒), 这里是**第二道**:
#     防的是"有人用 /scoreboard 直接把自己的分数设成 1"这种旁路。
execute if score #dev zx.meta matches 1 as @a[scores={zx.dbg_cd=1..}] run function sweetdream:debug/tg_cd
execute unless score #dev zx.meta matches 1 as @a[scores={zx.dbg_cd=1..},tag=zx.admin] run function sweetdream:debug/tg_cd
execute if score #dev zx.meta matches 1 as @a[scores={zx.dbg_mana=1..}] run function sweetdream:debug/tg_mana
execute unless score #dev zx.meta matches 1 as @a[scores={zx.dbg_mana=1..},tag=zx.admin] run function sweetdream:debug/tg_mana
execute if score #dev zx.meta matches 1 as @a[scores={zx.dbg_fadd=1..}] run function sweetdream:debug/tg_fadd
execute unless score #dev zx.meta matches 1 as @a[scores={zx.dbg_fadd=1..},tag=zx.admin] run function sweetdream:debug/tg_fadd
execute if score #dev zx.meta matches 1 as @a[scores={zx.dbg_fdel=1..}] run function sweetdream:debug/tg_fdel
execute unless score #dev zx.meta matches 1 as @a[scores={zx.dbg_fdel=1..},tag=zx.admin] run function sweetdream:debug/tg_fdel
execute if score #dev zx.meta matches 1 as @a[scores={zx.dbg_give=1..}] run function sweetdream:debug/tg_give
execute unless score #dev zx.meta matches 1 as @a[scores={zx.dbg_give=1..},tag=zx.admin] run function sweetdream:debug/tg_give
