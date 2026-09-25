# ------------------------------------------------------------
# internal/mana/mod_clear_all —— 清空全部恢复修正
# 【宏参数】manacore:work.a {uuid}
# 【做法】整个 regen_mods 重置成 8 个空槽的固定结构。
# ------------------------------------------------------------
$data modify storage manacore:players "$(uuid)".regen_mods set value {"0":{},"1":{},"2":{},"3":{},"4":{},"5":{},"6":{},"7":{}}
