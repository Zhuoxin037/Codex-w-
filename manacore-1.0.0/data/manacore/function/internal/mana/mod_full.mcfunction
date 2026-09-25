# ------------------------------------------------------------
# internal/mana/mod_full —— 修正槽位已满
# 【返回】out.success = 0b, out.reason = "regen_mod_full"
# 【怎么办】① 把 config.settings.max_regen_mods 调大, 同时按注释同步
#         扩写 mod_find_driver / regen_driver / sum_driver / mod_remove_driver
#         的展开次数与默认模板长度;
#         ② 或者让装备系统先自己累加, 只写一条汇总修正(推荐)。
# ------------------------------------------------------------
data modify storage manacore:out r.success set value 0b
data modify storage manacore:out r.reason set value "regen_mod_full"
