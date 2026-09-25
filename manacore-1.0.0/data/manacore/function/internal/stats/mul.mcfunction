# ------------------------------------------------------------
# internal/stats/mul —— 属性乘法(仅数值)
# 【宏参数】manacore:work.a {uuid,key,value}
# 【守卫】value 存在 且 目标 key 存在, 才执行 mul_calc。
# 【典型用途】给玩家挂 +20% 最大魔力的增益: mul key=max_mana value=1.2
# ------------------------------------------------------------
$execute if data storage manacore:work a.value if data storage manacore:players "$(uuid)".stats."$(key)" run function manacore:internal/stats/mul_calc with storage manacore:work a
