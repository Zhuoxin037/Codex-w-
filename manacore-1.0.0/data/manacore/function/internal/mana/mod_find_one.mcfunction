# ------------------------------------------------------------
# internal/mana/mod_find_one —— 检查第 i 个槽位是否可用
# 【宏参数】manacore:work.entry {uuid,i}
# 【判断】没有 value 字段(空槽) 且 #free 还没被占用 -> #free = i
# 【为什么用 value 判断占用】空槽位是 {} , 用 {} 做 if data 判断永远为真,
#         必须检查一个"只有真实修正才会有的字段"。
# ------------------------------------------------------------
$execute unless data storage manacore:players "$(uuid)".regen_mods."$(i)".value if score #free manacore.math matches -1 run execute store result score #free manacore.math run data get storage manacore:work entry.i
