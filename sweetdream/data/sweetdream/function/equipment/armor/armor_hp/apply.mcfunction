# ============================================================
# sweetdream:equipment/armor/armor_hp/apply —— 下"生命上限"modifier(宏 {amt})
# ------------------------------------------------------------
# 【为什么单独一个文件】`attribute ... modifier add <id> <值>` 的那个值**必须是
#   命令行里的字面量**，算出来的分数塞不进去 —— 只能靠宏展开(同 fcv4 破甲 / 体外供能)。
# 【执行者】那个玩家   【id 固定】sweetdream:eqp_ah_hp（摘除时也按它）
# ============================================================

$attribute @s minecraft:max_health modifier add sweetdream:eqp_ah_hp $(amt) add_value
