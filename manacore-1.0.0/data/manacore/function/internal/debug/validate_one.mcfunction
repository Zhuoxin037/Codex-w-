# ============================================================
# internal/debug/validate_one —— 单玩家数据自检
# ------------------------------------------------------------
# 【宏参数】manacore:work.a {uuid,slot}(由 index/visit 传入)
# 【检查项】
#   ① 索引存在但玩家数据缺失  -> 报错并顺手清掉脏索引(自愈)
#   ② 缺少 stats 字段          -> 提示需要重新注册
#   ③ 当前魔力 > 最大魔力      -> 提示数据异常(通常由外部直接改数据导致)
#   ④ 术阵槽位数量不是 8        -> 提示结构被破坏(不要手动删列表元素)
# 【为什么要有这个系统】手工改数据 / 多包冲突最容易破坏结构, 自检能第一
#   时间定位"哪个人、哪个字段"出问题, 而不用去翻庞大的 NBT。
# ============================================================
$execute unless data storage manacore:players "$(uuid)" run function manacore:internal/debug/warn_missing with storage manacore:work a
$execute if data storage manacore:players "$(uuid)" unless data storage manacore:players "$(uuid)".stats run function manacore:internal/debug/warn_nostats with storage manacore:work a
$execute if data storage manacore:players "$(uuid)".stats.current_mana if data storage manacore:players "$(uuid)".stats.max_mana run function manacore:internal/debug/check_mana with storage manacore:work a
$execute if data storage manacore:players "$(uuid)".formations unless data storage manacore:players "$(uuid)".formations."7" run function manacore:internal/debug/warn_formations with storage manacore:work a
