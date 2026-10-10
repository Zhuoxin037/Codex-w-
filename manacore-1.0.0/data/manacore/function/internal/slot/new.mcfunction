# ------------------------------------------------------------
# internal/slot/new —— 开一个新槽位
# 【做法】全局计数器 #next_slot 自增 1, 再复制给该玩家的 manacore.slot。
# 【上限保护】超过 #max_slots 时调用 slot/overflow, 计一次溢出。
# 【★ F04 修(2026-10-10)】原来 overflow 把 #next_slot **回绕到 1**, 随后这里无条件
#   `@s slot = #next_slot` ⇒ register 会把 index."1" 覆盖成新玩家, 而旧玩家仍持有
#   slot=1 ⇒ 两人索引归属冲突(self_uuid/心跳/mana API 全作用到错的人)。
#   现在 overflow 只置 #slot_full 标记、"不回绕也不覆盖": 满了就**拒绝分配**,
#   把 @s 槽位清 0(明确未注册), 由 reissue 跳过登记; 玩家下一秒会自然重试。
# 【想扩容】把 config.settings.max_slots 调大后 reload。
# ------------------------------------------------------------
scoreboard players add #next_slot manacore.meta 1
execute if score #next_slot manacore.meta > #max_slots manacore.meta run function manacore:internal/slot/overflow
execute if score #slot_full manacore.meta matches 0 run scoreboard players operation @s manacore.slot = #next_slot manacore.meta
execute if score #slot_full manacore.meta matches 1 run scoreboard players set @s manacore.slot 0
