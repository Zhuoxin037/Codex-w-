# ------------------------------------------------------------
# internal/formation/dur_sec —— 术阵时长的"秒 -> tick"换算
# 【原理】duration_seconds x 20(四舍五入)。
# ------------------------------------------------------------
execute store result score #dur manacore.math run data get storage manacore:work a.duration_seconds 20
