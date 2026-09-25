# ============================================================
# test:internal/damage_go —— 用纯数字字符串执行 /damage
# ------------------------------------------------------------
# 【宏参数】test:work a {target,num_str,type}
#   target  : 选择器字符串, 可以匹配多个实体, 例如 "@e[type=!#test:no_damage]"
#   num_str : 由 test:lib/num/plain 产出的纯数字字符串
#   type    : 伤害类型, 例如 minecraft:magic / minecraft:generic
# 【为什么用 execute as, 而不是直接 damage <选择器>】
#   /damage 的 target 参数只接受"单个实体"。传一个允许多个实体的选择器会直接
#   报错: "只允许一个实体, 但提供的选择器允许多个实体", 命令根本不会执行。
#   execute as <选择器> 等价于"轮流把匹配到的实体当执行者", 每次都拿 @s
#   (必然是单个)当目标, 范围伤害就能正常生效了。
# 【代价】by 不能再写 @s —— execute as 之后 @s 已经是被打的那个人了。
#   所以这里只做纯伤害, 不带击杀归属(不影响数值, 只影响死亡提示和击退归属)。
#   真要归属: 把目标改成 limit=1, 在命令末尾补 by <单个实体选择器>。
# 【为什么整行都以 $ 开头】宏替换只对 $ 开头的行生效, 这是硬性要求。
# 【出参】test:out r.applied = 1b
# 【提醒】applied 只说明这行命令跑过了。选择器没匹配到实体时 execute as 会
#   执行 0 次, 但这行依然会跑。
# 【负数保护】/damage 的数值参数不接受负数(会直接报参数错误), 所以这里先看
#   数字串的首字符, 是 "-" 就一律当 0。这样即使上游给了残留的或异常的负值,
#   也只是打不出伤害, 而不是整条命令报错。
# ============================================================

data modify storage test:work a.head set string storage test:work a.num_str 0 1
execute if data storage test:work a{head:"-"} run data modify storage test:work a.num_str set value "0"

$execute as $(target) run damage @s $(num_str) $(type)
data modify storage test:out r.applied set value 1b
