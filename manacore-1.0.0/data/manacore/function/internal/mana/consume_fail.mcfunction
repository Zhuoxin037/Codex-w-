# ------------------------------------------------------------
# internal/mana/consume_fail —— 魔力不足分支
# 【作用】只置位结果标记, 不改动任何玩家数据。技能流程会据此中断。
# ------------------------------------------------------------
data modify storage manacore:out r.success set value 0b
data modify storage manacore:out r.reason set value "mana"
