# ============================================================
# sweetdream:equipment/staff/five_curses/armor_apply —— 第四世破甲: 下 modifier(宏)
# ------------------------------------------------------------
# 【宏参数】storage zx:work fcv {arm, tou} —— 都是**负数**(基础值的 -50%)。
# 【为什么单独一个文件】`attribute ... modifier add <值>` 的数值必须是命令行里的
#   字面量, 只能靠宏参数展开; 而宏函数要求"调用那一刻参数就已绑定", 所以把
#   计算(armor_cut)和施加(本文件)拆开, 由 armor_cut 带着 storage 调进来。
# 【id 固定】sweetdream:fcv4_arm / sweetdream:fcv4_tou —— 摘除时也按这两个 id。
# ============================================================

$attribute @s minecraft:armor modifier add sweetdream:fcv4_arm $(arm) add_value
$attribute @s minecraft:armor_toughness modifier add sweetdream:fcv4_tou $(tou) add_value
