# ============================================================
# sweetdream:debug/num_pair —— 打印一行"两个浮点数"(省版面用)
# ------------------------------------------------------------
# 【宏参数】zx:work np {k1,l1,c1,k2,l2,c2}      【执行者】玩家本人
#   两个数都从 zx:work pl 下面取, 见 num_row 的说明。
# 【为什么值得单独做一个】聊天栏一行放得下两组"标签 数值", 两两并排能把
#   原来 10 行压到 5 行; 而且同一行里的两组天然对齐, 看起来像一张表。
# 【流程】取数①->去后缀->存 v1 -> 取数②->去后缀->存 v2 -> 交给渲染层。
#   中间这一步之所以要"存下来", 见 num_row 里关于宏参数定死时机的说明。
# ============================================================

# ---- 左半 ----
#   【先删再取】键读不到时不能拿上一行残留的旧值顶上(2026-10-03 补)。
data remove storage zx:work a.num
$execute if data storage zx:work pl.$(k1) run data modify storage zx:work a.num set from storage zx:work pl.$(k1)
function sweetdream:lib/num/plain
data modify storage zx:work np.v1 set from storage zx:work a.num_str

# ---- 右半 ----
data remove storage zx:work a.num
$execute if data storage zx:work pl.$(k2) run data modify storage zx:work a.num set from storage zx:work pl.$(k2)
function sweetdream:lib/num/plain
data modify storage zx:work np.v2 set from storage zx:work a.num_str

function sweetdream:debug/num_pair_go with storage zx:work np
