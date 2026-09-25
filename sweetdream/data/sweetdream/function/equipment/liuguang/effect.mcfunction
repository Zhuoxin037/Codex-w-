# ============================================================
# sweetdream:equipment/liuguang/effect —— 把算好的伤害真正打出去
# ------------------------------------------------------------
# 【谁调用它】liuguang/damage 的最后一步:
#     function sweetdream:equipment/liuguang/effect with storage zx:work a
#   注意传的是"一个复合标签", 不是单个数字。
#   宏参数必须是复合标签, 传单个 double 会直接报错, 函数根本不会被调用。
#   节点里有: manacore:out 的全部字段(damage 等) + uuid。
# 【这一步在干嘛】命令的数值参数只能是写在命令文本里的字面量, 没法直接引用
#   NBT 路径。所以要把 $(damage) 先变成字符串 "37.5"(宏渲染出来的原样是
#   "37.5d", 末尾那个 d 是 NBT 类型标记, 命令解析器不认), 再拼进 /damage。
#   sweetdream:lib/num/plain 干的就是这件事, 出参是 sweetdream:work a.num_str。
# 【想改打谁】改下面那行的 distance / 目标条件就行。
# ============================================================

# ① 宏值 -> 工作节点。
#    宏渲染出来是 37.5d, 而 SNBT 里 37.5d 正好是合法的 double 写法,
#    所以这行不管渲染带不带后缀都能正确解析。
data modify storage zx:work a set value {num:0.0}
$data modify storage zx:work a.num set value $(damage)

# ② 归一化成 double 并去掉类型后缀 -> sweetdream:work a.num_str = "37.5"
function sweetdream:lib/num/plain

# ③ 补上命令需要的其他参数
data modify storage zx:work a.target set value "@e[type=!#sweetdream:no_damage,distance=0.1..3]"
data modify storage zx:work a.type set value "minecraft:player_attack"

# ④ 把 UUID 的 4 个整数搬进节点 —— 下一层要用它们拼"只指向我"的选择器
#    必须在这里搬: 宏变量在函数被调用时就固定了, 下一层才拿得到 $(u0)..$(u3)。
$data modify storage zx:work a.u0 set from storage manacore:players "$(uuid)".u0
$data modify storage zx:work a.u1 set from storage manacore:players "$(uuid)".u1
$data modify storage zx:work a.u2 set from storage manacore:players "$(uuid)".u2
$data modify storage zx:work a.u3 set from storage manacore:players "$(uuid)".u3

# ⑤ 打出去(带攻击者归属 -> 击杀算在你头上)
#    注意: /damage 的目标参数只收单个实体, 范围选择器由下一层用 execute as 展开。
function sweetdream:internal/damage/with_from with storage zx:work a

# ⑥ 想再补一个状态效果就用这行(去掉开头的 # 即可), 例如:
# data modify storage zx:in arg set value {target:"@e[type=!#sweetdream:no_damage,distance=0.1..3]",effect:"minecraft:glowing",duration:10}
# function sweetdream:api/effect
