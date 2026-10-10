# ============================================================
# sweetdream:lib/in_restore —— 把 manacore:in arg 恢复成上一次 in_bak 的样子(★ 备份栈: 弹栈)
# ------------------------------------------------------------
# 【和 lib/in_bak 成对使用】见 in_bak 的说明(含"为什么必须改成栈")。
# 【为什么"本来没有"也要管】栈顶若是哨兵 {__absent:1b}, 这里就把 in arg **删掉**,
#   不会凭空造出一个 in arg 来。
# 【为什么要弹栈(删栈顶)】不删的话, 下一次 in_restore 会拿到同一份旧备份反复放回,
#   凭空多出一份别人早就用完的参数。栈空了就把整个节点删掉, 不留空 list。
# 【弹空时什么都不做】栈顶取不到 = 栈空(或压根没 push 过), 于是不碰 in arg。
# ============================================================

# ① 取栈顶(先清临时, 免得取不到时留着上一份)
data remove storage zx:work in_top
execute if data storage zx:bak in[0] run data modify storage zx:work in_top set from storage zx:bak in[0]
# ② 按栈顶内容恢复: 哨兵 -> 删掉 in arg; 其余 -> 整份放回
execute if data storage zx:work in_top{__absent:1b} run data remove storage manacore:in arg
execute if data storage zx:work in_top unless data storage zx:work in_top{__absent:1b} run data modify storage manacore:in arg set from storage zx:work in_top
# ③ 弹栈 + 空栈清理
execute if data storage zx:bak in[0] run data remove storage zx:bak in[0]
execute unless data storage zx:bak in[0] run data remove storage zx:bak in
# ④ 清临时
data remove storage zx:work in_top
