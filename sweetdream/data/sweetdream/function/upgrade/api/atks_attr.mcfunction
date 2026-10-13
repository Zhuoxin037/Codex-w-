# ============================================================
# sweetdream:upgrade/api/atks_attr —— 把攻击速度修正挂回玩家身上(宏)
# ------------------------------------------------------------
# 【宏参数】sweetdream:work a {num_str}   —— ★ 用 num_str 不是 num ★
#   attribute 的数值参数只能是**写在命令文本里的字面量**, 想引用存储里的值
#   只能走"宏拼字符串"。而宏渲染 DoubleTag 会带类型后缀(0.1 -> "0.1d"),
#   命令解析器不认 —— 所以调用方必须先过 lib/num/plain 把后缀砍掉,
#   这里拿到的 $(num_str) 才是 "0.1" 这样的纯数字。
#   (本包既有先例: sculk_echo 的 ...run damage @s $(num_str) $(type)。)
# 【属性 id 本件独有】sweetdream:upg_atkspeed —— 和套装/脊骨共生的 id 分开, 各摘各的。
# 【为什么是 attack_speed】神经衰弱石改的就是原版攻速; 满蓄力闸(lib/atk_charge)
#   也是 `attribute @s minecraft:attack_speed get 100` 读它 ⇒ 加成能吃到。
# ============================================================

$attribute @s minecraft:attack_speed modifier add sweetdream:upg_atkspeed $(num_str) add_value
