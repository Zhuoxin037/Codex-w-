# ------------------------------------------------------------
# internal/join/reissue —— 重新分配槽位
# 【做什么】调用 slot/alloc(优先吃回收池, 否则新开号), 把结果写回宏节点,
#           再走 register。
# 【注意】slot/alloc 只在"槽位对不上"时才会跑, 正常上线路径不会触发,
#           所以不会出现"每次上线都换槽位"的情况。
# ------------------------------------------------------------
function manacore:internal/slot/alloc
execute store result storage manacore:macro a.slot int 1 run scoreboard players get @s manacore.slot
function manacore:internal/join/register with storage manacore:macro a
