# ------------------------------------------------------------
# internal/mana/mod_remove —— 按 id 删除修正
# 【宏参数】manacore:work.a {uuid,id}
# 【做什么】把参数搬进 work.entry, 交给展开式删除驱动。
# 【用途】卸下装备 / 被动技能失效 / 手动清 buff。
# ------------------------------------------------------------
$data modify storage manacore:work entry set value {uuid:"$(uuid)",i:0,id:"$(id)"}
function manacore:internal/mana/mod_remove_driver with storage manacore:work entry
