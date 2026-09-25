# ------------------------------------------------------------
# internal/player/resolve —— 槽位号 -> 玩家记录
# 【宏参数】manacore:work.a {i}
# 【做法】把 index."i" 整份复制到 manacore:work.entry(独立节点, 之后所有
#         子步骤都以它为宏参数), 有内容就执行秒逻辑。
# 【为什么要先 remove】entry 是复用节点, 上一次的残留会让 if data 误判,
#         所以先清空再复制。
# ------------------------------------------------------------
execute if data storage manacore:work entry run data remove storage manacore:work entry
$execute if data storage manacore:index "$(i)" run data modify storage manacore:work entry set from storage manacore:index "$(i)"
execute if data storage manacore:work entry run function manacore:internal/player/second_macro with storage manacore:work entry
