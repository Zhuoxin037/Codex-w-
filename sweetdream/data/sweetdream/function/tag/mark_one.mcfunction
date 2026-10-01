# @s = 单只目标。先验证名称；非法输入不能修改状态或生成显示实体。
$data modify storage zx:tag request set value {mark:"$(mark)"}
execute unless data storage zx:tag request{mark:"yuanhai"} unless data storage zx:tag request{mark:"liuhuo"} unless data storage zx:tag request{mark:"yehuo"} unless data storage zx:tag request{mark:"shixin"} unless data storage zx:tag request{mark:"dream"} run return 0
execute unless entity @s[tag=zx.tags_v2] run function sweetdream:tag/migrate
$tag @s add zx.status.$(mark)
function sweetdream:tag/icon_refresh
