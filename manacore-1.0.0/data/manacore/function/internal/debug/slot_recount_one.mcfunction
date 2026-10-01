# 试一个槽位(宏 {i}): 有记录就把"最大占用槽"记下来; 空记录(uuid:"")直接清掉
$execute if data storage manacore:index "$(i)" unless data storage manacore:index "$(i)"{uuid:""} run scoreboard players set #max_used manacore.meta $(i)
$execute if data storage manacore:index "$(i)"{uuid:""} run data remove storage manacore:index "$(i)"