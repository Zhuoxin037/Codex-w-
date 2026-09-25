# ------------------------------------------------------------
# internal/formation/tick_check —— 到期时间比较
# 【宏参数】manacore:work.entry {uuid,i}
# 【逻辑】end <= #now -> tick_expire(清除)
# 【#now】框架的游戏刻时钟, 与冷却共用同一条时间轴, 因此"冷却 10 秒"
#   与"术阵持续 10 秒"永远同步。
# ------------------------------------------------------------
$execute store result score #fend manacore.math run data get storage manacore:players "$(uuid)".formations."$(i)".end
execute if score #fend manacore.math <= #now manacore.meta run function manacore:internal/formation/tick_expire with storage manacore:work entry
