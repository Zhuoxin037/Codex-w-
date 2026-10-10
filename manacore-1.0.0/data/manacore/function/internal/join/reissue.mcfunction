# ------------------------------------------------------------
# internal/join/reissue —— 重新分配槽位
# 【做什么】调用 slot/alloc(优先吃回收池, 否则新开号), 把结果写回宏节点,
#           再走 register。
# 【注意】slot/alloc 只在"槽位对不上"时才会跑, 正常上线路径不会触发,
#           所以不会出现"每次上线都换槽位"的情况。
# 【★ F04 修(2026-10-10)】槽位耗尽时 slot/alloc 会置 #slot_full=1 —— 这时**不能**
#   再往下登记(否则 index 会被写到空槽/别人的槽上)。直接跳过 register,
#   玩家保持"未注册"状态、下一秒自然重试(见 internal/session/tick_self)。
# ------------------------------------------------------------
function manacore:internal/slot/alloc
execute if score #slot_full manacore.meta matches 1 run return 0
execute store result storage manacore:macro a.slot int 1 run scoreboard players get @s manacore.slot
function manacore:internal/join/register with storage manacore:macro a
