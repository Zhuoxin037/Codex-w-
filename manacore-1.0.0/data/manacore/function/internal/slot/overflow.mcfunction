# ------------------------------------------------------------
# internal/slot/overflow —— 槽位耗尽保护
# 【做什么】把 #slot_overflow 计数 +1(供 /function manacore:debug/validate
#         报告), 并置 #slot_full=1 表示"本秒拒绝分配"。
# 【★ F04 修(2026-10-10)】原来还顺手把 #next_slot 回绕到 1, 于是下一句
#   `@s slot = #next_slot` 会把 index."1" **覆盖**成新玩家 —— 而旧玩家仍持有
#   slot=1, 两人索引冲突。现在**不回绕**: 只置标记 + 把 #next_slot 夹到上限,
#   slot/new 见到标记就不再写 @s 槽位; reissue 跳过登记 ⇒ 自然重试。
# 【看到这提示怎么办】调大 config.settings.max_slots(例如 128/256)后 /reload,
#   或检查是否有玩家数据没被正常回收。
# ------------------------------------------------------------
scoreboard players add #slot_overflow manacore.meta 1
scoreboard players set #slot_full manacore.meta 1
scoreboard players operation #next_slot manacore.meta = #max_slots manacore.meta
