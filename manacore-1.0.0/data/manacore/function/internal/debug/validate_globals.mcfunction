# ------------------------------------------------------------
# internal/debug/validate_globals —— 全局(非单玩家)检查
# 【检查项】① 槽位是否发生过回绕(说明 max_slots 太小)
#          ② #next_slot 是否已越过 max_slots
#          ③ 打印当前槽位使用量, 方便判断还能容纳多少人
# 【说明】#slot_overflow 由 internal/slot/overflow 累加, 只增不减。
# ------------------------------------------------------------
execute if score #slot_overflow manacore.meta matches 1.. run tellraw @s [{"text":"[校验] 槽位曾回绕(请调大 config.settings.max_slots)","color":"yellow"}]
execute if score #next_slot manacore.meta > #max_slots manacore.meta run tellraw @s [{"text":"[校验] next_slot 已超过 max_slots","color":"red"}]
tellraw @s [{"text":"[校验] 已登记槽位上限 ","color":"gray"},{"score":{"name":"#next_slot","objective":"manacore.meta"}},{"text":" / "},{"score":{"name":"#max_slots","objective":"manacore.meta"}}]
