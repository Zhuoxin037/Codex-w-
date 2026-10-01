# ============================================================
# manacore:internal/uuid/migrate —— 把老键(残缺 8 位)的数据迁到新键(宏 {h0,uuid})
# 【为什么单独一层】上一版把它和"拼 uuid"写在同一个宏里, 那一行出问题就整个宏都不干活;
#   拆开后: 拼 uuid 不依赖宏, 迁移失败也只影响迁移本身。
# 【老键长啥样】以前 UUID 只拼出前 8 位 -> 老键就是 hex 的前 8 位(正好 = h0)。
# ============================================================

$execute if data storage manacore:players."$(h0)" unless data storage manacore:players."$(uuid)" run data modify storage manacore:players."$(uuid)" set from storage manacore:players."$(h0)"