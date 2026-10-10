# ============================================================
# sweetdream:lib/in_bak —— 备份"公共输入口" manacore:in arg(★ 备份栈: 压栈)
# ------------------------------------------------------------
# 【为什么要备份】manacore:in arg 是全局唯一的输入口 —— 谁调前置包的接口,
#   谁就要往这里写参数; 写完接口把它读走, 这个口子就该是空的。
#   问题是"后台逻辑"也在用它: 观测镜每刻要查术阵数量, 装备被动每秒要读魔力。
#   它们写进去之后如果不还, 你在聊天栏手填的参数就会被冲掉 ——
#   症状就是 /data get storage manacore:in arg 只剩下一个 uuid。
# 【用法】把"整段后台逻辑"夹在中间, 就像这样:
#     function sweetdream:lib/in_bak
#     ... 你自己的每秒/每刻逻辑(里面可以随便用 in arg) ...
#     function sweetdream:lib/in_restore
# 【和 api 接口不冲突】前置包的 api/* 只"读"in arg, 从来不写它,
#   所以套在任意调用外面都是安全的。
#
# 【★★ 嵌套安全吗 —— 2026-10-10 起安全(修 F15)★★】
#   原来用的是**单层**节点 zx:bak in, 所以写死了"谁都不能再嵌一层"。
#   可事实上**一直有嵌套**(不是理论问题):
#     · core/tick 的每刻保护段(第 55 行 in_bak … 第 402 行 in_restore)
#       里面会调到 debug/tg_router -> debug/*, 而 debug/* 自己又 in_bak;
#     · lib/second 的保护段(第 10 行 … 第 93 行)里第 74 行调 upgrade/second,
#       而 upgrade/second 自己又 in_bak —— ★ 这条**每秒**都在发生 ★。
#   单层栈的后果: 里层 in_bak 把外层刚存下的"真参数"覆盖成"当前这份已被污染的
#   值", 里层 in_restore 再把污染值放回并删掉备份 —— 外层 in_restore 时备份早没了,
#   ⇒ **聊天栏手填的公共参数永久丢失**, 正是 in_bak 本要防的那件事。
#   现在改成**栈**: 每次 in_bak 往 index 0 压一份, in_restore 从 index 0 弹走,
#   push/pop 一一对应, 嵌多少层都不会互相顶掉。
# 【"本来就没有 in arg"也要记】当前 in arg 不存在时压入哨兵 {__absent:1b},
#   in_restore 见到哨兵就把 in arg 删掉, 而不是"恢复成空 compound"。
# 【谁负责清栈】core/load 每次 /reload 都把整个 zx:bak in 删掉 ——
#   顺带清掉"旧版单层结构(compound)"和任何脏栈, 不用在这里判类型。
# ============================================================

# ① 保证栈存在(list, 栈顶 = 下标 0)
execute unless data storage zx:bak in run data modify storage zx:bak in set value []
# ② 压栈
execute if data storage manacore:in arg run data modify storage zx:bak in prepend from storage manacore:in arg
execute unless data storage manacore:in arg run data modify storage zx:bak in prepend value {__absent:1b}
