# ------------------------------------------------------------
# internal/debug/purge_registry_del —— 删掉 a.uuid 对应的 players 记录(宏叶子)
# 【宏参数】manacore:work.a {uuid}
# 【谁调用它】internal/debug/purge_registry_go(每轮读好 a.uuid 后调一次)
# 【为什么单独一层(★ N03 修, 2026-10-11)★】
#   带 `with` 的宏函数里, `$(var)` 在**进入本函数时**一次性冻结。
#   所以"写 a.uuid"和"用 $(uuid)"**绝不能放在同一个函数里** —— 那样 $(uuid)
#   拿到的是调用前的旧值(整体 off-by-one, 清单最后一项永远删不掉)。
#   这里作为**下一次函数调用**, 进入时读到的正是 go 刚写进 a.uuid 的本轮 uuid ⇒ 正确。
#   (同坑: scan_go 首发 / 坑 96; 正解形态 = 驱动器写宏源 + 叶子读 $(var)。)
# 【删之前先判存在】清单里可能留着"记录已经被删掉"的 uuid(管理员 purge_one、
#   玩家被 reset 等) —— 路径不存在时 data remove 无副作用, 先判一下更干净。
# ------------------------------------------------------------
$execute if data storage manacore:players "$(uuid)" run data remove storage manacore:players "$(uuid)"
