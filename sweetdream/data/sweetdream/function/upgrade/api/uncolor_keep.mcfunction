# ============================================================
# sweetdream:upgrade/api/uncolor_keep —— 消升级时"留在物品上"的那条: 记账 + 搬进新列表(宏 {keep})
# ------------------------------------------------------------
# 【干什么】uncolor_go 逐槽重建 up 列表时, 对**槽号 < 被消槽**的旧条目调它:
#   ① 把 id 记进 zx:work kept."<id>" 键集 —— uncolor_give 递归返还整条链时
#      跳过这些"物品上本来就还有的"条目, 免得凭空多发
#      (老物品同系残留两条时才会遇到)。
#   ② 原样搬进 zx:work newlist(uncolor_go 最后整体写回物品)。
# 【为什么值为 1b】只要"键存在"就够了, uncolor_give 判的是
#   `unless data storage zx:work kept."$(id)"`。
# ============================================================

$data modify storage zx:work kept."$(keep)" set value 1b
$data modify storage zx:work newlist append value "$(keep)"
