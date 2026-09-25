# ------------------------------------------------------------
# lib/num/plain —— 双精度 -> 可直接放进命令的"纯数字字符串"
# 【为什么需要它】宏替换时, DoubleTag 会被渲染成 "12.5d"(带 d 后缀),
#         而 /damage、/attribute 这类命令的参数用的是 Java 的
#         Double.parseDouble, 不认 d 后缀, 直接替换会报参数错误。
# 【做法】1) execute store ... double 先把输入强制成 double(保证类型可控)
#         2) 用宏写成字符串 raw
#         3) 看 raw 的末位是不是类型后缀(d/f), 是才用
#            data modify ... set string <raw> 0 -1 把它切掉, 得到 "12.5"
#        第 3 步的"先判断再切"是为了不依赖"宏渲染一定带后缀"这个假设。
# 【输入】manacore:work.a.num     【输出】manacore:work.a.num_str
# 【优势】不管数值是整数、小数、负数还是科学计数法, 都能得到合法字面量。
# ------------------------------------------------------------
execute unless data storage manacore:work a.num run data modify storage manacore:work a.num set value 0.0
execute store result storage manacore:work a.num double 1 run data get storage manacore:work a.num
function manacore:internal/fmt/plain with storage manacore:work a
