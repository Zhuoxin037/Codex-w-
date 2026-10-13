# ============================================================
# sweetdream:equipment/staff/triad/armor_apply —— 强化热刀削甲: 下 modifier(宏)
# ------------------------------------------------------------
# 【宏参数】storage zx:work tri {v} —— 护甲的增减值(负数)。
# 【为什么单独一个文件】`attribute ... modifier add <值>` 的数值必须是命令行里的
#   字面量, 只能靠宏参数展开(全包同款, 见 brain_leech / five_curses 的破甲)。
# ============================================================

$attribute @s minecraft:armor modifier add sweetdream:tri_fire_arm $(v) add_value
