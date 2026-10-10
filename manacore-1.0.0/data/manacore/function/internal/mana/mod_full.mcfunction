# ------------------------------------------------------------
# internal/mana/mod_full —— 修正槽位已满
# 【返回】out.success = 0b, out.reason = "regen_mod_full"
# 【怎么办】槽位数是**硬编码 8**(regen_mods 的 "0".."7"), 改 settings 没用 ——
#         2026-10-08 更正旧注释(它写"把 max_regen_mods 调大就行", 实际做不到):
#         ① 要更多槽位, 得同时扩写 mod_find_driver / regen_driver / sum_driver /
#            mod_remove_driver 的展开次数、核心默认模板长度、以及 boot 里的常量;
#         ② 或者让装备系统先自己累加, 只写一条汇总修正(推荐)。
# ------------------------------------------------------------
data modify storage manacore:out r.success set value 0b
data modify storage manacore:out r.reason set value "regen_mod_full"
