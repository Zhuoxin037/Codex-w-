# ============================================================
# sweetdream:internal/damage/go —— 用纯数字字符串执行 /damage
# ------------------------------------------------------------
# 【宏参数】sweetdream:work a {target,num_str,type}
#   target  : 选择器字符串, 可以匹配多个实体, 例如 "@e[type=!#sweetdream:no_damage]"
#   num_str : 由 sweetdream:lib/num/plain 产出的纯数字字符串
#   type    : 伤害类型, 例如 minecraft:player_attack(吃护甲) / minecraft:magic(穿甲)
# 【为什么用 execute as, 而不是直接 damage <选择器>】
#   /damage 的 target 参数只接受"单个实体"。传一个允许多个实体的选择器会直接
#   报错: "只允许一个实体, 但提供的选择器允许多个实体", 命令根本不会执行。
#   execute as <选择器> 等价于"轮流把匹配到的实体当执行者", 每次都拿 @s
#   (必然是单个)当目标, 范围伤害就能正常生效了。
# 【代价】by 不能再写 @s —— execute as 之后 @s 已经是被打的那个人了。
#   所以这里只做纯伤害, 不带击杀归属(不影响数值, 只影响死亡提示和击退归属)。
#   真要归属: 把目标改成 limit=1, 在命令末尾补 by <单个实体选择器>。
# 【为什么整行都以 $ 开头】宏替换只对 $ 开头的行生效, 这是硬性要求。
# 【出参】sweetdream:out r.applied = 1b
# 【提醒】applied 只说明这行命令跑过了。选择器没匹配到实体时 execute as 会
#   执行 0 次, 但这行依然会跑。
# 【负数保护】/damage 的数值参数不接受负数(会直接报参数错误), 所以这里先看
#   数字串的首字符, 是 "-" 就一律当 0。这样即使上游给了残留的或异常的负值,
#   也只是打不出伤害, 而不是整条命令报错。
# ============================================================

# 记一笔"最近一次 /damage 长什么样", 给 /function sweetdream:debug/damage 排查用
$data modify storage zx:data last.num set value "$(num_str)"
$data modify storage zx:data last.type set value "$(type)"
$data modify storage zx:data last.target set value "$(target)"
scoreboard players add #dbg_calls zx.meta 1

data modify storage zx:work a.head set string storage zx:work a.num_str 0 1
execute if data storage zx:work a{head:"-"} run data modify storage zx:work a.num_str set value "0"

# 【★ 记下这次 /damage 到底成功没有 ★】命令在函数里失败是**静默**的: 不报错、
#   不写日志, 只表现为"看起来放出来了但一点伤害都没有"。最常见的失败原因是
#   伤害类型没注册进世界(damage_type 是注册表, /reload 补不上, 必须重进世界)。
#   所以这里把成败记进 #dbg_dmg, 用 /function sweetdream:debug/damage 看。
#   ⚠️ 目标有多只时, 这个分数只保留**最后一只**的结果。
#   ⚠️⚠️ 【这行全文件只能出现一次】2026-10-03 踩过: 给这行加"记录成败"的包装时,
#     把原来那行替换成了带 store success 的版本, 却忘了删掉底部那条 —— 于是
#     /damage 被执行了**两遍**, 全包所有伤害(不止真实伤害)都变成两倍。
#     因为两遍都带 `store success`, 两边结果一样, 光看 #dbg_dmg 根本发现不了。
#     → 以后要给这行加东西, 先搜一遍本文件里有没有第二条 `run damage @s`。
$execute as $(target) run execute store success score #dbg_dmg zx.meta run damage @s $(num_str) $(type)

# 【★★ 类型没注册时会发生什么: 什么都发生不了 ★★】
#   damage_type 是**注册表**内容, 新加的类型要**退出世界重进**才会存在,
#   `/reload` 补不上。在那之前 /damage 的**类型参数解析不了**。
#   【为什么这里没有"失败就用 sweetdream:skill 再打一次"的兜底】
#     Minecraft 的规则是: **宏函数里只要有一行求值后解析不了, 整个函数就不会
#     被调用、里面一条命令都不跑**(见 Minecraft Wiki「Function (Java Edition)」,
#     以及 MC-277015)。所以上面那行一旦解析失败, 写在它**后面**的任何兜底
#     都不可能执行 —— 那样写只会给人"已经兜住了"的错觉, 比不写更糟。
#   结论: 新增 damage_type 之后**必须退出世界重进**(不是 /reload、不是重启客户端)。
#     没重进 = 这两处真实伤害**静默不生效**(不报错、不写日志)。
#     用 /function sweetdream:debug/true_damage 一秒确认类型在不在。

data modify storage zx:out r.applied set value 1b
