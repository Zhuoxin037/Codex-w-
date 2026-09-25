# ------------------------------------------------------------
# internal/mana/apply —— 魔力操作分派器
# 【宏参数】manacore:work.a {uuid,op,value}
# 【为什么用 op 分派】set / add / remove / remove_max 四种操作的入口逻辑
#         完全一样(合并默认值 -> 定位玩家 -> 分派), 只有最后一步不同。
#         用一个 op 字段分派, 可以让 api/mana/* 每个接口只剩 4 行。
# 【当前支持】set(直接设为 X) / add(加上 X) / remove(减去 X)
#             / remove_max(削减最大魔力)
# 【扩展】新增操作只需在这里加一条分支 + 一个 *_body 函数。
# ------------------------------------------------------------
execute if data storage manacore:work a{op:"set"} run function manacore:internal/mana/set_body with storage manacore:work a
execute if data storage manacore:work a{op:"add"} run function manacore:internal/mana/add_body with storage manacore:work a
execute if data storage manacore:work a{op:"remove"} run function manacore:internal/mana/remove_body with storage manacore:work a
execute if data storage manacore:work a{op:"remove_max"} run function manacore:internal/mana/remove_max_body with storage manacore:work a
