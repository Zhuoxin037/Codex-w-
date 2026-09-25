# ------------------------------------------------------------
# internal/debug/warn_missing —— 索引指向了不存在的玩家数据
# 【宏参数】manacore:work.a {uuid,slot}
# 【处理】警告 + 计数, 并直接删掉这条脏索引(否则每秒遍历都白跑)。
# ------------------------------------------------------------
scoreboard players add #warn manacore.math 1
$tellraw @s [{"text":"[校验] 索引里有记录但玩家数据缺失: ","color":"red"},{"text":"$(uuid)","color":"white"},{"text":" 槽位 ","color":"gray"},{"text":"$(slot)","color":"white"}]
$execute if data storage manacore:index "$(slot)" run data remove storage manacore:index "$(slot)"
