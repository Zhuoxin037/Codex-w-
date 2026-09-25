# ------------------------------------------------------------
# internal/mana/regen_base —— 读取基础每秒恢复
# 【宏参数】manacore:work.entry {uuid}
# 【作用】stats.mana_regen x1000 -> 计分板 #regen(框架统一的"本次恢复量"累加器)
# 【默认值】新玩家为 1.0, 即"每秒恢复 1 点魔力"(需求里的初始值)。
# ------------------------------------------------------------
$execute store result score #regen manacore.math run data get storage manacore:players "$(uuid)".stats.mana_regen 1000
