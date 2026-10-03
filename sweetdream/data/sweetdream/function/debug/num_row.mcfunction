# ============================================================
# sweetdream:debug/num_row —— 打印一行"浮点数"(单个)
# ------------------------------------------------------------
# 【宏参数】zx:work nr {k, l, c, s}      【执行者】玩家本人
#   k = 键名, 从 zx:work pl 下面取(如 "stats.base_attack")
#   l = 中文标签   c = 颜色   s = 尾巴备注
#
# 【★ 为什么不能直接把 nbt 打出来 ★】
#   {"nbt":...,"storage":...} 渲染 DoubleTag 时会带上 NBT 类型后缀 ——
#   屏幕上是 "9.0d"、"1.0d" 这样, 很难看。所以借 lib/num/plain 把后缀砍掉,
#   转成**字符串**再打。
#
# 【★ 为什么同一个键不能只靠一层宏 ★】
#   宏参数在"函数被调用那一刻"就定死了, 同一次调用里算出来的 num_str 没法
#   再当宏变量用。所以要拆两层: 这一层负责取数, 算完把结果写回同一个参数
#   对象(nr.num_str), 再交给 num_row_go 重新取一次参数。
#
# 【数据从哪来】统一从 zx:work pl 取 —— debug/stats 会把"面板 + 原版属性 +
#   前置包接口返回的临时值"全部先归一化到那一个节点下面, 于是这里不用管来源。
# ============================================================

# ① 取数(没这个键就跳过)
#   【先删再取】读不到键时 a.num 必须是"没有", 不能是上一行残留的旧值 ——
#   不然 num_row 会把上一个数原样再打一遍, 还看起来特别像真的(2026-10-03 补)。
data remove storage zx:work a.num
$execute if data storage zx:work pl.$(k) run data modify storage zx:work a.num set from storage zx:work pl.$(k)

# ② 去后缀 —— 结果落在 zx:work a.num_str
function sweetdream:lib/num/plain

# ③ 把结果补回参数对象, 交给渲染层
data modify storage zx:work nr.num_str set from storage zx:work a.num_str
function sweetdream:debug/num_row_go with storage zx:work nr
