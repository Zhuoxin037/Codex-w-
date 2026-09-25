# ------------------------------------------------------------
# internal/mana/mod_clear —— 清空第 i 个修正槽位
# 【宏参数】manacore:work.entry {uuid,i}
# 【做法】把槽位写回空复合 {}。用 {} 而不是删除元素, 是为了保持 8 槽的
#         固定结构, 让展开式循环永远有确定的索引范围。
# ------------------------------------------------------------
$data modify storage manacore:players "$(uuid)".regen_mods."$(i)" set value {}
