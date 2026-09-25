# ------------------------------------------------------------
# internal/formation/slot_one —— 检查第 i 个槽位是否为空
# 【宏参数】manacore:work.entry {uuid,i}
# 【判断】没有 id 字段(空槽) 且 #free 还没被占用 -> #free = i
# 【为什么用 id 判断】空槽是 {}, 用 {} 做 if data 永远为真,
#   必须检查"只有真实术阵才会有的字段"。
# ------------------------------------------------------------
# 按 i 从 0..7 顺序调用, 只记录第一个空槽
$execute unless data storage manacore:players "$(uuid)".formations."$(i)".id if score #free manacore.math matches -1 run execute store result score #free manacore.math run data get storage manacore:work entry.i
