# 试一个槽位(宏 {uuid,i}): 这个槽记的就是他 -> 记住槽号并置"已找到"
$execute if data storage manacore:index "$(i)"{uuid:"$(uuid)"} run scoreboard players set #found_slot manacore.meta $(i)
$execute if data storage manacore:index "$(i)"{uuid:"$(uuid)"} run scoreboard players set #found manacore.meta 1