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
# ============================================================

$execute if entity @a[nbt={UUID:[I;$(u0),$(u1),$(u2),$(u3)]},limit=1] as $(target) run damage @s $(num_str) $(type) by @a[nbt={UUID:[I;$(u0),$(u1),$(u2),$(u3)]},limit=1]
$execute unless entity @a[nbt={UUID:[I;$(u0),$(u1),$(u2),$(u3)]},limit=1] as $(target) run damage @s $(num_str) $(type)
