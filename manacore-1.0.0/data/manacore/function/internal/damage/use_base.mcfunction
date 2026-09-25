# ------------------------------------------------------------
# internal/damage/use_base —— base_attack 传 -1 时改用玩家面板
# 【宏参数】manacore:work.a {uuid}
# 【为什么这么设计】大多数技能吃"玩家当前攻击力", 但也有一些技能是固定
#   伤害(与面板无关)。用 -1 当哨兵值, 一套接口同时支持两种情况。
# ------------------------------------------------------------
$execute store result score #base manacore.math run data get storage manacore:players "$(uuid)".stats.base_attack 1000
