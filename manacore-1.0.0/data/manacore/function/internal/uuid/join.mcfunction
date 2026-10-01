# ============================================================
# manacore:internal/uuid/join —— 用宏一次性拼出标准 UUID(宏 {h0,h1,h2,h3,h4})
# ------------------------------------------------------------
# 【为什么要宏】命令文本里没法直接拼接字符串: `data modify ... append` 只对**列表**生效,
#   对字符串用 append 会静默失败 —— 这正是"UUID 只有 8 位"的病根(优化建议第 1 条)。
#   宏变量替换本身就是"文本拼接", 一把就能拼成 8-4-4-4-12。
# 【顺带做的事】把老键(残缺的 8 位)迁移到新键上, 免得修好之后玩家数据看起来被清空。
#   老的残缺键 = 十六进制的前 8 位, 正好就是 h0。
# ============================================================

$data modify storage manacore:work a.uuid set value "$(h0)-$(h1)-$(h2)-$(h3)-$(h4)"
$execute if data storage manacore:players."$(h0)" unless data storage manacore:players."$(h0)-$(h1)-$(h2)-$(h3)-$(h4)" run data modify storage manacore:players."$(h0)-$(h1)-$(h2)-$(h3)-$(h4)" set from storage manacore:players."$(h0)"