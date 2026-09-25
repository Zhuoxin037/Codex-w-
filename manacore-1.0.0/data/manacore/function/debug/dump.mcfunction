# ============================================================
# debug/dump —— 打印某个玩家的完整数据
# ------------------------------------------------------------
# 【用法】
#   看自己: /function manacore:debug/dump
#   看别人: /data modify storage manacore:in arg set value {uuid:"<UUID>"}
#           /function manacore:debug/dump
# 【输出】stats / flags / cooldowns / regen_mods / formations 的原始 NBT
# 【实现】用 tellraw 的 {"nbt":"路径","storage":"manacore:players"} 组件
#   直接把存储渲染成文字, 所以能看到最真实的数据(包括不该出现的东西)。
# 【注意】请在玩家身份下执行(消息发给 @s)。
# ============================================================
data modify storage manacore:work a set value {}
data modify storage manacore:work a merge from storage manacore:in arg
execute unless data storage manacore:work a.uuid run function manacore:debug/dump_self
execute if data storage manacore:work a.uuid run function manacore:internal/debug/dump with storage manacore:work a
