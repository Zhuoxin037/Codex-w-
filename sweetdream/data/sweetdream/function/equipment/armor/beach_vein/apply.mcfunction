# ============================================================
# sweetdream:equipment/armor/beach_vein/apply —— 下/换"护甲值"modifier(宏 {amt})
# ------------------------------------------------------------
# 【为什么单独一个文件】`attribute ... modifier add <id> <值>` 的值必须是命令行
#   里的字面量，算出来的分数塞不进去 —— 只能靠宏展开（同 fcv4 / armor_hp/apply）。
# 【执行者】那个玩家   【id 固定】sweetdream:bv_arm（摘除时也按它）
# ============================================================

$attribute @s minecraft:armor modifier add sweetdream:bv_arm $(amt) add_value
