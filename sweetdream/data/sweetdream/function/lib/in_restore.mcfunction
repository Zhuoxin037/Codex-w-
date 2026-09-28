# ============================================================
# sweetdream:lib/in_restore —— 把 manacore:in arg 放回备份的样子
# ------------------------------------------------------------
# 【和 lib/in_bak 成对使用】见 in_bak 的说明。
# 【为什么"本来没有"也要管】备份时如果 in arg 根本不存在, 就把 zx:bak in
#   删掉; 于是这里什么都不做 —— 不会凭空造出一个 in arg 来。
# 【为什么用完就删备份】不删的话, 下一次"in arg 本来不存在"的情况会把这个
#   旧备份放回去, 凭空多出一份别人早就用完的参数。
# ============================================================

execute if data storage zx:bak in run data modify storage manacore:in arg set from storage zx:bak in
execute if data storage zx:bak in run data remove storage zx:bak in
