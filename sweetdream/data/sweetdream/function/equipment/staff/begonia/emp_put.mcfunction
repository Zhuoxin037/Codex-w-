# ============================================================
# sweetdream:equipment/staff/begonia/emp_put —— 漩涡增强命中: 往池子里 +20
# ------------------------------------------------------------
# 【谁调用它】hook_calc 最后一步(三个判据全过了才进来)
# 【为什么单独一个文件】宏函数里不能再写普通判据行? 不 —— 是为了把
#   "$execute if entity ..." 那条宏行和"写池子"拆开: hook_calc 里 Storage 路径
#   bgc 已经备好, 这里只负责写池(照 lib/dmg_add_put 的调用模板)。
# 【+20 写进 mm 通道】不消费 —— 增强跟着漩涡寿命走(见 hook_calc 头注释)。
# ============================================================

data modify storage zx:work put set value {pct:20,ch:"mm"}
function sweetdream:lib/dmg_add_put with storage zx:work put
