# ------------------------------------------------------------
# internal/mana/mod_dur_sec —— 修正时长的"秒 -> tick"换算
# 【原理】duration_seconds x 20, 四舍五入取整。
# ------------------------------------------------------------
execute store result score #dur manacore.math run data get storage manacore:work a.duration_seconds 20
