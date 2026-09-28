# ============================================================
# sweetdream:lib/in_bak —— 备份"公共输入口" manacore:in arg
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
# 【嵌套安全吗】用的是 zx:bak in 这一个节点, 所以**不要**自己再嵌一层
#   同样的备份; 需要嵌套就用别的节点名(观测镜就另用了 zx:look.saved_in)。
# ============================================================

execute if data storage manacore:in arg run data modify storage zx:bak in set from storage manacore:in arg
execute unless data storage manacore:in arg run data remove storage zx:bak in
