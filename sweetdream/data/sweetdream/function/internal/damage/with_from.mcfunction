# ============================================================
# sweetdream:internal/damage/with_from —— 带"攻击者归属"的打伤害
# ------------------------------------------------------------
# 【宏参数】sweetdream:work a {target,num_str,type,u0,u1,u2,u3}
# 【和 internal/damage_go 的区别】这一份会在 /damage 后面补 by <攻击者>,
#   于是击杀会被记在攻击者头上(死亡信息、经验掉落归属)。
# 【为什么要用 u0..u3 拼选择器】UUID 文本没法写进选择器, 而玩家记录里存了
#   UUID 的 4 个 32 位整数, 用它们能反查出玩家实体。
# 【为什么第二行要有】万一那个选择器选不到人(玩家刚好离线), by 会指向空,
#   整条命令就会失败、一点伤害都打不出。所以选不到时退回"无归属"的写法。
# 【为什么选择器要写两遍, 不先存进节点再引用】宏变量在"函数被调用那一刻"就
#   固定了。在函数体里才写进节点的 from, 这一层是引用不到的(会报缺少传入参数)。
#   所以直接内联, 别绕。
# 【为什么还要 execute as】/damage 的目标参数只收单个实体, 用 execute as
#   把范围选择器逐个展开成 @s。
# 【★ 真正的伤害动作现在在 internal/damage/one ★】
#   因为黄昏黎明之交界 需要"打之前看它带不带通用标签, 打完之后看它死没死" ——
#   只有以"单个目标"身份执行才做得了这些检查, 所以这里只负责把范围拆成一个个人。
# 【★ one 现在不含宏行了 ★】真正的 /damage 搬进了 internal/damage/deal 那个宏,
#   one 自己会去读 zx:work a。所以这里**裸调** one 即可(不必再 with storage)。
# 【★ 兜底补 u0..u3 ★】有的调用点(流光/超限流光)只写了 num/target/type, 没带 u0..u3。
#   宏参数缺字段会让 deal 那条宏"缺少传入参数"整条调用失败 -> 伤害**静默消失**。
#   这里补默认 0。
# ============================================================

execute unless data storage zx:work a.u0 run data modify storage zx:work a.u0 set value 0
execute unless data storage zx:work a.u1 run data modify storage zx:work a.u1 set value 0
execute unless data storage zx:work a.u2 run data modify storage zx:work a.u2 set value 0
execute unless data storage zx:work a.u3 run data modify storage zx:work a.u3 set value 0

# ============================================================
# 【★★★ 把这一批的完整入参抄进专用基准节点 zx:work ob ★★★】
# ------------------------------------------------------------
# 【为什么要抄】一次范围伤害会 `execute as <选择器>` 逐个目标打。而 zx:work a 是
#   **全包共用的一个临时节点**(226 处引用: 流光/法球/物品备份/击杀记账/调试…),
#   任何一次嵌套调用都可能往它里面写东西。所以"这一批的原始伤害"不能只留在 a 里,
#   必须放一个**别的函数一律不碰**的节点 —— 就是 ob。
# 【谁在用 ob】只有这里写、internal/damage/one 读(每只目标开工时复原)。
# 【为什么用"整体拷贝"而不是挑几个字段】one 每次都要把 deal 需要的入参
#   (num_str / type / u0..u3 / damage)复原成"这一批的样子"; 整体抄一份最省事、
#   也不会漏字段。ob 是一次性快照, 下一批直接覆盖, 不需要清理。
# 【★ 2026-10-04 第三轮修复 ★】
#   前两轮用的是"就地改 a.damage/a.num_str, 打完再还原"。还原**本身是对的**,
#   但它有个致命前提: 循环中途没人动 a。只要有一次嵌套调用(击杀记账 /
#   物品备份 / 升级结算 / 流光回调…)碰了 a, 还原就失手 —— 表现就是
#   "升痕加伤有时漏给没升痕的目标", 随机、难复现(玩家原话: 有时候生效有时候不)。
#   换成"从 ob 复原"之后, 无论中途谁动过 a, 每只目标都在开打前被重新拉回基准值。
# ============================================================

data modify storage zx:work ob set from storage zx:work a

$execute as $(target) run function sweetdream:internal/damage/one
