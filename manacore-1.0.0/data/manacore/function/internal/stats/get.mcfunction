# ------------------------------------------------------------
# internal/stats/get —— 通用属性读取
# 【宏参数】manacore:work.a {uuid,key}
# 【原理】key 直接参与路径拼接: players."uuid".stats."$(key)"
#         这就是"宏函数调用"最典型的用法——用变量当字段名。
# 【出参】manacore:out.value(取不到时为 0.0) / out.key / out.uuid
# 【为什么先 set value 0.0】避免上次调用残留的数值被误读成结果。
# 【注意】stats 下的键可以是任意名字, 所以这套接口天然支持你自己扩展
#         新属性(例如 "crit_rate"), 不需要改框架。
# ------------------------------------------------------------
data modify storage manacore:out r.value set value 0.0
$execute if data storage manacore:players "$(uuid)".stats."$(key)" run data modify storage manacore:out r.value set from storage manacore:players "$(uuid)".stats."$(key)"
$data modify storage manacore:out r.key set value "$(key)"
$data modify storage manacore:out r.uuid set value "$(uuid)"
