# ============================================================
# sweetdream:equipment/axe/sunken_weight/speed_sync —— 按层数同步移速修饰符
# ------------------------------------------------------------
# 每层 -4%，最多 5 层 = -20%。
# 【★ 为什么是 5 个固定 id 而不是一个动态 id ★】
#   modifier 的 add_value 只能是**字面量**，动态值要靠宏把数字拼进命令
#   （heal_up 那种写法）。这里每层只有 −0.04 一个常量，用 w1..w5 五个固定 id
#   按"加到第几层"逐个挂/摘 —— 不需要宏、也不会出现 double 渲染成 "…d" 的问题。
# 【成对加减】每次进来先把 5 个全摘掉，再按当前层数挂回去。
#   摘下不存在的 id 会失败，但**不会吞掉后面的命令**（包内 lib/unfreeze_one 同款）。
# ============================================================
attribute @s minecraft:movement_speed modifier remove sweetdream:sw_w1
attribute @s minecraft:movement_speed modifier remove sweetdream:sw_w2
attribute @s minecraft:movement_speed modifier remove sweetdream:sw_w3
attribute @s minecraft:movement_speed modifier remove sweetdream:sw_w4
attribute @s minecraft:movement_speed modifier remove sweetdream:sw_w5

execute if score @s zx.sw_n matches 1.. run attribute @s minecraft:movement_speed modifier add sweetdream:sw_w1 -0.04 add_multiplied_base
execute if score @s zx.sw_n matches 2.. run attribute @s minecraft:movement_speed modifier add sweetdream:sw_w2 -0.04 add_multiplied_base
execute if score @s zx.sw_n matches 3.. run attribute @s minecraft:movement_speed modifier add sweetdream:sw_w3 -0.04 add_multiplied_base
execute if score @s zx.sw_n matches 4.. run attribute @s minecraft:movement_speed modifier add sweetdream:sw_w4 -0.04 add_multiplied_base
execute if score @s zx.sw_n matches 5.. run attribute @s minecraft:movement_speed modifier add sweetdream:sw_w5 -0.04 add_multiplied_base
