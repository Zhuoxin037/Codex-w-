# ------------------------------------------------------------
# internal/cooldown/start_done —— 冷却时长为 0
# 【场景】冷却缩减堆到 100%(缩减比例 = 1)时, 打完折就是 0 刻。
# 【做法】把该技能的冷却记录删掉(而不是写一条 0 长度记录), 这样
#         check 会直接判定 ready, 且不会留下垃圾数据。
# ------------------------------------------------------------
$execute if data storage manacore:players "$(uuid)".cooldowns."$(skill)" run data remove storage manacore:players "$(uuid)".cooldowns."$(skill)"
data modify storage manacore:out r.remaining set value 0
