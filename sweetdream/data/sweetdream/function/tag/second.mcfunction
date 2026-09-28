# ============================================================
# sweetdream:tag/second —— 通用标签的每秒同步(挂在 #manacore:event/second)
# ------------------------------------------------------------
# 【做两件事】
#   ① 全量刷新: 每个被标记的生物重算一次图标(缺了重造 / 标签变了换图 / 全摘了收掉)
#   ② 孤儿回收: 生物没了但图标还在的, 收掉
# 【开销】只遍历"带 zx.tagged 的生物"和"带 zx.icon 的图标", 没标记时几乎为零。
# ============================================================

execute as @e[tag=zx.tagged] at @s run function sweetdream:tag/icon_refresh

# ② 孤儿回收(生物死了 / 被清掉了, 图标不能留在原地)
#   做法: 先假设所有图标都是孤儿, 再让"活着的生物"把自己的图标认领回来,
#   最后还挂着 zx.orphan 的就是没主的。
#   ★ 为什么不靠"图标身上记的生物编号": 上一版就是靠它, 结果一处编号对不上
#     (比如重复贴标签换了编号)就永远收不掉。现在只认"生物自己的编号 + 图标标签",
#     而且认领是"活着才算", 生物一死必然收得掉。
tag @e[type=minecraft:text_display,tag=zx.icon] add zx.orphan
execute as @e[tag=zx.tagged] run function sweetdream:tag/claim_one
kill @e[type=minecraft:text_display,tag=zx.orphan]
