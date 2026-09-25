# ------------------------------------------------------------
# debug/dump_self —— 未指定 uuid 时解析"自己"
# 【做什么】把自己的槽位号读进 manacore:work.a.i, 由宏函数查出 UUID。
# 【技巧】scoreboard players add ... 0 既保证分数存在(不存在则建 0),
#   又能把当前值作为命令返回值取出, 一步完成"读值 + 防报错"。
# ------------------------------------------------------------
execute store result storage manacore:work a.i int 1 run scoreboard players add @s manacore.slot 0
function manacore:internal/debug/self_uuid with storage manacore:work a
