# ------------------------------------------------------------
# internal/session/beat_write —— 写入当前秒号(宏参数 {uuid,slot})
# 【注意】$(slot) 位于引号键内部, 属于"任何替换结果都合法"的安全位置。
# ------------------------------------------------------------
$execute store result storage manacore:index "$(slot)".beat int 1 run scoreboard players get #sec manacore.meta
