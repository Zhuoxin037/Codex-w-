# ============================================================
# sweetdream:equipment/staff/triad/more_one —— 额外攻击的一步(递归)
# ------------------------------------------------------------
# 【循环变量】#tri_more zx.meta —— 计到 3 收工, 也就是补 **2** 下(1、2 各一次)。
# 【★ 为什么不能用宏参数 $(i) ★】宏参数在"调用那一刻"就冻结, "同一个函数里既写宏源
#   又读 $(i)"是经典 off-by-one(坑 96)。循环变量走**计分项**, 每层读到的都是最新值。
# 【★ 调用方必须先把 #tri_more 归零 ★】计分项不会自己清零: 第二次触发额外攻击时
#   若不清, 会从上次的值接着涨 ⇒ 直接越过 3 收工, 一下都补不上(零日志)。
#   (坑 146 同族: 计数器型诊断锚必须有归零点。)
# ============================================================

scoreboard players add #tri_more zx.meta 1
execute if score #tri_more zx.meta matches 3.. run return 0

execute as @e[tag=zx.ball_hit] at @s run function sweetdream:equipment/staff/triad/hit_once

function sweetdream:equipment/staff/triad/more_one
