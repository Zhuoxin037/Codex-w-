# ------------------------------------------------------------
# internal/slot/overflow —— 槽位耗尽保护
# 【做什么】把 #slot_overflow 计数 +1(供 /function manacore:debug/validate
#         报告), 并把 #next_slot 回绕到 1。
# 【看到这条提示怎么办】调大 config.settings.max_slots(例如 128/256),
#         然后 /reload。或检查是否有玩家数据没被正常回收。
# ------------------------------------------------------------
scoreboard players add #slot_overflow manacore.meta 1
scoreboard players set #next_slot manacore.meta 1
