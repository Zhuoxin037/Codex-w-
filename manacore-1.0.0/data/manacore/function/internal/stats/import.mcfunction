# ------------------------------------------------------------
# internal/stats/import —— 批量导入属性
# 【宏参数】manacore:work.a {uuid,stats}
# 【语义】merge = 来源覆盖同名字段, 未提到的字段保持不变(标准"打补丁"语义)。
#         所以这里可以安全地只传想改的那几项。
# 【和 join/existing 的区别】那边是"缺了才补", 这边是"给了就覆盖"。
# ------------------------------------------------------------
$execute if data storage manacore:players "$(uuid)" run data modify storage manacore:players "$(uuid)".stats merge from storage manacore:work a.stats
