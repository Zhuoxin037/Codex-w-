# ------------------------------------------------------------
# internal/debug/purge_registry_go —— "终身清单"的递归体
# 【宏参数】manacore:work.a {i,uuid}
# 【做什么】删掉清单第 i 项对应的 players 记录, 然后 i+1 继续。
# 【终止条件】★ 首行守卫: 第 i 项不存在 = 已经走过清单末尾 -> return 0。
#   清单是 append-only 的连续列表(循环期间不动它), 所以"元素不存在"就等于到头了。
#   ★ 这样写**不需要知道清单长度** —— 不依赖 `data get <列表>` 的返回值语义。
#   ★ 用"元素存在性"当判据也有直接先例: internal/slot/alloc 就是
#     `execute if data storage manacore:free_slots list[0]`(那个列表装的是整数)。
# 【为什么用递归】宏函数写不了循环, 本包统一"自己调自己 + 计分板下标"
#   (同 internal/index/loop、internal/index/find_uuid_loop)。
# 【为什么每轮都要抄 uuid】路径与选择器都不能带变量, 只有宏能展开文本,
#   所以每轮先把清单那一项抄进同一个宏参数节点, 让 `$(uuid)` 有值可展开。
# 【清单元素是裸字符串】`list[i]` 直接就是 uuid 文本(不是 {u:"…"}) —— 因为登记
#   只在"记录诞生处"发生、天然不会重复, 所以**不需要**用列表过滤谓词判"登记过没"。
# 【删之前先判存在】清单里可能留着"记录已经被删掉"的 uuid(管理员 purge_one、
#   玩家被 reset 等) —— 路径不存在时 data remove 会失败, 先判一下更干净。
# ------------------------------------------------------------
$execute unless data storage manacore:players_all list[$(i)] run return 0
$data modify storage manacore:work a.uuid set from storage manacore:players_all list[$(i)]
$execute if data storage manacore:players "$(uuid)" run data remove storage manacore:players "$(uuid)"
scoreboard players add #pli manacore.meta 1
execute store result storage manacore:work a.i int 1 run scoreboard players get #pli manacore.meta
function manacore:internal/debug/purge_registry_go with storage manacore:work a
