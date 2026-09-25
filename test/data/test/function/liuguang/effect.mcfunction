# ============================================================
# test:liuguang/effect —— 把算好的伤害真正打出去
# ------------------------------------------------------------
# 【谁调用它】liuguang/damage 的最后一步:
#     function test:liuguang/effect with storage manacore:out r
#   注意传的是 r(整个复合标签), 不是 r.damage。
#   宏参数必须是"一个复合标签", 传单个 double 会直接报错, 函数根本不会被调用。
#   传 r 之后, r 里的每个键都变成宏变量: $(damage) / $(success) / ...
# 【这一步在干嘛】命令的数值参数只能是写在命令文本里的字面量, 没法直接引用
#   NBT 路径。所以要把 $(damage) 先变成字符串 "37.5"(宏渲染出来的原样是
#   "37.5d", 末尾那个 d 是 NBT 类型标记, 命令解析器不认), 再拼进 /damage。
#   test:lib/num/plain 干的就是这件事, 出参是 test:work a.num_str。
# 【想改打谁】改下面那行的 distance / 目标条件就行。
# ============================================================

# ① 宏值 -> 工作节点。
#    宏渲染出来是 37.5d, 而 SNBT 里 37.5d 正好是合法的 double 写法,
#    所以这行不管渲染带不带后缀都能正确解析。
data modify storage test:work a set value {num:0.0}
$data modify storage test:work a.num set value $(damage)

# ② 归一化成 double 并去掉类型后缀 -> test:work a.num_str = "37.5"
function test:lib/num/plain

# ③ 补上命令需要的其他参数, 然后执行
#    注意: /damage 的目标参数只收单个实体, 所以这里给的是范围选择器,
#    由 internal/damage_go 用 execute as 逐个处理。
data modify storage test:work a.target set value "@e[type=!#test:no_damage,distance=..3]"
data modify storage test:work a.type set value "minecraft:magic"
function test:internal/damage_go with storage test:work a

# ④ 想再补一个状态效果就用这行(去掉开头的 # 即可), 例如:
# data modify storage test:in arg set value {target:"@e[type=!#test:no_damage,distance=..3]",effect:"minecraft:glowing",duration:10}
# function test:api/effect
