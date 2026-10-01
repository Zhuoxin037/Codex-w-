# ============================================================
# manacore:debug/slot_recount —— 重算"已登记槽位上限"(修槽位泄漏)
# ------------------------------------------------------------
# 【什么时候用】发现 #next_slot 涨得离谱(比如 2 个人却占了 18 格)时, 跑一次:
#     /function manacore:debug/slot_recount
# 【它做什么】把 index 里 0..max_slots 全扫一遍: 清掉空记录, 找出真正被占用的最大槽号,
#   然后把 #next_slot 设成"最大槽号 + 1"。
# 【注意】它**不会**重新编号已有玩家的槽(那会连带术阵/回魔/冷却的存储路径一起乱),
#   只是把"下一个空槽"的指针拉回来 —— 已经泄漏掉的那些空槽, 下次分配时会重新用上。
# ============================================================
scoreboard players set #max_used manacore.meta 0
scoreboard players set #i manacore.meta 0
function manacore:internal/debug/slot_recount_loop
scoreboard players set #i manacore.meta 0
scoreboard players operation #next_slot manacore.meta = #max_used manacore.meta
scoreboard players add #next_slot manacore.meta 1
tellraw @s [{"text":"[ManaCore] 已重算槽位上限: ","color":"gold"},{"score":{"name":"#next_slot","objective":"manacore.meta"},"color":"white"},{"text":" (最大已用槽 ","color":"gray"},{"score":{"name":"#max_used","objective":"manacore.meta"},"color":"white"},{"text":")","color":"gray"}]