# ============================================================
# fallendream:equipment/armor/condensed_shell/ol_end_one —— 超限·凝壳：给一只还冻着的生物 +2 秒
# ------------------------------------------------------------
# 【谁调它】ol_end：`as @e[type=!#fallendream:no_damage,tag=zx.freeze,distance=..3]`
# 【执行者】领域收尾那一刻还在冰冻的那一只
# 【★ 为什么拆一层 ★】lib/freeze 的宏参数要从 storage 取，而 storage 是全局一份；
#   放在一个函数里"打标签→立刻调宏"，避免两次选择器之间实体死了/走出范围造成错位。
# ============================================================

data modify storage zx:work fz set value {target:"@s",ticks:40}
function fallendream:lib/freeze with storage zx:work fz
