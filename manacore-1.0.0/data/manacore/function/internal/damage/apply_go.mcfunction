# ------------------------------------------------------------
# internal/damage/apply_go —— 执行 /damage
# 【宏参数】manacore:work.a {target,type,from,num_str}
# 【命令】execute as $(target) run damage @s $(num_str) $(type) by $(from)
# 【为什么用 execute as 而不是直接 damage <选择器>】
#   /damage 的 target 参数只接受"单个实体"。传一个允许多个实体的范围选择器会
#   直接报 "只允许一个实体, 但提供的选择器允许多个实体", 命令根本不会执行 ——
#   表现就是范围技能完全没伤害。execute as 等于"轮流把匹配到的每个实体当执行
#   者", 每次都拿 @s(必然只有一个)当目标, 范围伤害才能正常生效。
# 【没有目标时】execute as 会执行 0 次, 不会抛异常, 上层技能流程照常收尾
#   (这也是原来 if entity 那层保护现在不需要了的原因)。
# 【归属】by 用的还是 $(from)。from 通常是由 from_auto 拼出来的
#   "@a[nbt={UUID:[I;...]},limit=1]" 这种按 UUID 锁定的绝对选择器,
#   execute as 之后它依然指向真正的攻击者, 击杀归属正常。
#   只有 from 推导失败退化成 "@s" 时, 归属会算在被打击者头上(数值不受影响)。
# 【标记】out.applied = 1b。注意它只说明这行命令跑过了;
#   选择器没匹配到实体时上面执行 0 次, 这一行依然会跑。
# 【注意】num_str 必须是纯数字字符串(不能带 d/f 后缀), 见 lib/num/plain。
# ------------------------------------------------------------
$execute as $(target) run damage @s $(num_str) $(type) by $(from)
data modify storage manacore:out r.applied set value 1b
