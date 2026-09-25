# ------------------------------------------------------------
# internal/uuid/append —— 半字节值 -> 十六进制字符
# 【宏参数】$(prefix) = 已经拼好的字符串, 宏节点的 n = 半字节值(0..15)
# 【做法】16 条 execute if data 分支, 只有 n 相等的那条会执行;
#         把 "前缀 + 字符" 重新写回 work.a.hex。
# 【为什么不用查表列表】storage 里读列表元素同样需要宏索引, 反而更绕;
#         16 条 if 分支只有一条命中, 每次调用实际开销很小。
# 【注意】每个 $ 行里的 $(prefix) 都会在调用时被替换成实际字符串内容。
# ------------------------------------------------------------
$execute if data storage manacore:macro a{n:0} run data modify storage manacore:work a.hex set value "$(prefix)0"
$execute if data storage manacore:macro a{n:1} run data modify storage manacore:work a.hex set value "$(prefix)1"
$execute if data storage manacore:macro a{n:2} run data modify storage manacore:work a.hex set value "$(prefix)2"
$execute if data storage manacore:macro a{n:3} run data modify storage manacore:work a.hex set value "$(prefix)3"
$execute if data storage manacore:macro a{n:4} run data modify storage manacore:work a.hex set value "$(prefix)4"
$execute if data storage manacore:macro a{n:5} run data modify storage manacore:work a.hex set value "$(prefix)5"
$execute if data storage manacore:macro a{n:6} run data modify storage manacore:work a.hex set value "$(prefix)6"
$execute if data storage manacore:macro a{n:7} run data modify storage manacore:work a.hex set value "$(prefix)7"
$execute if data storage manacore:macro a{n:8} run data modify storage manacore:work a.hex set value "$(prefix)8"
$execute if data storage manacore:macro a{n:9} run data modify storage manacore:work a.hex set value "$(prefix)9"
$execute if data storage manacore:macro a{n:10} run data modify storage manacore:work a.hex set value "$(prefix)a"
$execute if data storage manacore:macro a{n:11} run data modify storage manacore:work a.hex set value "$(prefix)b"
$execute if data storage manacore:macro a{n:12} run data modify storage manacore:work a.hex set value "$(prefix)c"
$execute if data storage manacore:macro a{n:13} run data modify storage manacore:work a.hex set value "$(prefix)d"
$execute if data storage manacore:macro a{n:14} run data modify storage manacore:work a.hex set value "$(prefix)e"
$execute if data storage manacore:macro a{n:15} run data modify storage manacore:work a.hex set value "$(prefix)f"
