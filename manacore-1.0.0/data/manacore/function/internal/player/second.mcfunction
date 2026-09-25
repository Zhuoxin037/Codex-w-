# ------------------------------------------------------------
# internal/player/second —— 在线玩家每秒结算(以 @s 执行)
# 【做什么】把 @s 的槽位号读进 manacore:work.a.i, 交给 player/resolve
#           查出自己的 UUID, 再执行该玩家的每秒逻辑。
# 【为什么不在这里直接处理】秒逻辑里所有路径都要用到 UUID 文本(动态键名),
#           必须先经过一次宏替换把 UUID 拿到手。
# ------------------------------------------------------------
execute store result storage manacore:work a.i int 1 run scoreboard players get @s manacore.slot
function manacore:internal/player/resolve with storage manacore:work a
