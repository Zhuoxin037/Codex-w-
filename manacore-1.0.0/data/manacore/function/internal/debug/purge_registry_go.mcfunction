# ------------------------------------------------------------
# internal/debug/purge_registry_go —— "终身清单"的递归驱动器
# 【宏参数】manacore:work.a {i,uuid}
# 【做什么】删掉清单第 i 项对应的 players 记录, 然后 i+1 继续。
# 【终止条件】★ 首行守卫: 第 i 项不存在 = 已经走过清单末尾 -> return 0。
#   清单是 append-only 的连续列表(循环期间不动它), 所以"元素不存在"就等于到头了。
#   ★ 这样写**不需要知道清单长度** —— 不依赖 `data get <列表>` 的返回值语义。
#   ★ 用"元素存在性"当判据也有直接先例: internal/slot/alloc 就是
#     `execute if data storage manacore:free_slots list[0]`(那个列表装的是整数)。
# 【为什么用递归】宏函数写不了循环, 本包统一"自己调自己 + 计分板下标"
#   (同 internal/index/loop、internal/index/find_uuid_loop)。
# 【清单元素是裸字符串】`list[i]` 直接就是 uuid 文本(不是 {u:"…"}) —— 因为登记
#   只在"记录诞生处"发生、天然不会重复, 所以**不需要**用列表过滤谓词判"登记过没"。
# 【删之前先判存在】清单里可能留着"记录已经被删掉"的 uuid(管理员 purge_one、
#   玩家被 reset 等) —— 路径不存在时 data remove 会失败, 先判一下更干净。
# ------------------------------------------------------------
# 【★ N03 修(2026-10-11): "读 uuid 的层"与"用 uuid 的层"必须拆开 ★】
#   原写法在**同一个函数里**先 `a.uuid set from list[$(i)]`、紧接着又
#   `if data … "$(uuid)" run data remove …` —— 而带 `with` 的宏函数里, 所有
#   `$(var)` 在**进入本轮时就一次性冻结**成调用方写进宏源的值; 同层再改 a.uuid
#   不会影响本层已渲染的 `$(uuid)`。⇒ 第 21 行删的其实是**上一轮**的 uuid,
#   整体 off-by-one: 清单 [A,B] 只删到 A、漏 B; 清单 [A] 则 A 完全留存。
#   ⇒ 拆法: 本文件只负责"读本轮 uuid 进 a.uuid"(用 $(i)), 再用**新的函数调用**
#     `purge_registry_del`(它进入时读到刚写好的 a.uuid) 去删。两个变量的用法都
#     "跨调用才生效": `$(i)` 本轮读、下一轮用; `$(uuid)` 本轮写、del 层用。
#   ★ 这与坑 96(scan_go 首发)是同一个坑: "同一层里写宏源 + 用 $(var)" = 恒错。
# ------------------------------------------------------------
$execute unless data storage manacore:players_all list[$(i)] run return 0
$data modify storage manacore:work a.uuid set from storage manacore:players_all list[$(i)]
# ★ 必须交给**另一层**去用 $(uuid)(本层已冻结, 同层用 = off-by-one)
function manacore:internal/debug/purge_registry_del with storage manacore:work a
scoreboard players add #pli manacore.meta 1
execute store result storage manacore:work a.i int 1 run scoreboard players get #pli manacore.meta
function manacore:internal/debug/purge_registry_go with storage manacore:work a
