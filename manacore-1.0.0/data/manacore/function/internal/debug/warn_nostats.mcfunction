# ------------------------------------------------------------
# internal/debug/warn_nostats —— 玩家记录缺少 stats
# 【宏参数】manacore:work.a {uuid}
# 【处理办法】该玩家重新上线时会由 join/existing 自动补齐; 也可以调
#   api/player/reset 重建(注意会清空他现有的术阵与冷却)。
# ------------------------------------------------------------
scoreboard players add #warn manacore.math 1
$tellraw @s [{"text":"[校验] 缺少 stats 字段: ","color":"yellow"},{"text":"$(uuid)","color":"white"}]
