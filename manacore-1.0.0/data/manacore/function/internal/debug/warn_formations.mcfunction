# ------------------------------------------------------------
# internal/debug/warn_formations —— 术阵数组结构异常
# 【宏参数】manacore:work.a {uuid}
# 【原因】多半是外部对 formations 做了 append/remove, 破坏了"8 个固定槽位"
#   的约定。修复: /function manacore:api/formation/clear 会重建标准结构。
# ------------------------------------------------------------
scoreboard players add #warn manacore.math 1
$tellraw @s [{"text":"[校验] 术阵槽位数量异常(应为 8 个): ","color":"yellow"},{"text":"$(uuid)","color":"white"}]
