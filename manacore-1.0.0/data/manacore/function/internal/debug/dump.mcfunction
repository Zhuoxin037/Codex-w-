# ============================================================
# internal/debug/dump —— 打印某个玩家的完整数据
# ------------------------------------------------------------
# 【宏参数】manacore:work.a {uuid}
# 【实现】tellraw 的 {"nbt":"路径","storage":"manacore:players"} 组件可以
#   直接把存储里的原始 NBT 渲染成文字, 所以不需要手动拼格式化字符串。
#   路径里的 UUID 用 \" 转义后写进 JSON 字符串, 由宏替换填进去。
# 【输出内容】stats / flags / cooldowns / regen_mods / formations
# 【以谁的身份看】消息发给 @s —— 所以请在玩家身份下执行
#   (/execute as <玩家> run function manacore:debug/dump)。
# ============================================================
$execute unless data storage manacore:players "$(uuid)" run tellraw @s [{"text":"[ManaCore] 未找到该 UUID 的数据: ","color":"red"},{"text":"$(uuid)"}]
$execute if data storage manacore:players "$(uuid)" run tellraw @s [{"text":"==== ManaCore Dump ====","color":"aqua","bold":true}]
$execute if data storage manacore:players "$(uuid)" run tellraw @s [{"text":"UUID: ","color":"gray"},{"text":"$(uuid)","color":"white"}]
$execute if data storage manacore:players "$(uuid)" run tellraw @s [{"text":"stats: ","color":"gray"},{"nbt":"\"$(uuid)\".stats","storage":"manacore:players"}]
$execute if data storage manacore:players "$(uuid)" run tellraw @s [{"text":"flags: ","color":"gray"},{"nbt":"\"$(uuid)\".flags","storage":"manacore:players"}]
$execute if data storage manacore:players "$(uuid)" run tellraw @s [{"text":"cooldowns: ","color":"gray"},{"nbt":"\"$(uuid)\".cooldowns","storage":"manacore:players"}]
$execute if data storage manacore:players "$(uuid)" run tellraw @s [{"text":"regen_mods: ","color":"gray"},{"nbt":"\"$(uuid)\".regen_mods","storage":"manacore:players"}]
$execute if data storage manacore:players "$(uuid)" run tellraw @s [{"text":"formations: ","color":"gray"},{"nbt":"\"$(uuid)\".formations","storage":"manacore:players"}]
