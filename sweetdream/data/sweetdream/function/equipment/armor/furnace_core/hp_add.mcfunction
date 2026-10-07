# ============================================================
# sweetdream:equipment/armor/furnace_core/hp_add —— 按账本数值挂原版最大生命
# ------------------------------------------------------------
# 【宏参数】zx:work x {v}    【执行者】玩家
# 【为什么单独一个文件】modifier 的 add_value 只能是**字面量**, 不能直接接
#   score 或 storage; 想让它跟着账本变, 只能靠宏参数把数字拼进命令里。
#   (脊骨共生 spine_symbiote/hp_add 是同一套写法。)
# ============================================================

$attribute @s minecraft:max_health modifier add sweetdream:eqp_fc_hp $(v) add_value
