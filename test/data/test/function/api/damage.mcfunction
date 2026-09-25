# ============================================================
# test:api/damage —— 把数值打成伤害(公开接口)
# ------------------------------------------------------------
# 【调用模板】
#   data modify storage test:in arg set value {target:"@e[type=!#test:no_damage,distance=..3]", damage:37.5}
#   function test:api/damage
#   /data get storage test:out r.applied     -> 1b 说明命令执行了
#   /data get storage test:out r.damage      -> 实际用的伤害值
# 【入参】(全部写进 test:in arg, 没写的用默认值)
#   target  : 选择器字符串(必填, 留空则整个接口什么都不做)
#   damage  : 伤害数值, 默认 0.0
#   type    : 伤害类型, 默认 minecraft:magic(偏穿甲的法术伤害)
#             想受护甲减免就填 minecraft:generic, 想像玩家平砍就填 minecraft:player_attack
#   read    : 填 "manacore" 时, 忽略 damage, 直接从 manacore:out r.damage 取
#             —— 这就是"把 manacore 算出来的伤害用进 /damage"的开关
# 【target 可以是范围选择器】/damage 本身只收单个实体, 但本接口内部用
#   execute as 逐个处理, 所以写 "@e[type=!#test:no_damage,distance=..3]" 是对的。
# 【为什么要先 set value 再 merge】宏参数不能缺字段, 而且 work 节点是复用
#   的, 不覆盖就会沿用上一次调用的旧值。
# ============================================================

data modify storage test:work a set value {target:"",damage:0.0,type:"minecraft:magic",read:""}
data modify storage test:work a merge from storage test:in arg

# 出参先复位, 免得读到上一次调用的残留值
data modify storage test:out r.applied set value 0b
data modify storage test:out r.damage set value 0.0

# 可选: 从 manacore 的出口直接取伤害。
# 加一层 if data 保护: manacore 没装时这个存储不存在, 不加保护会报错中断。
execute if data storage test:work a{read:"manacore"} if data storage manacore:out r.damage run data modify storage test:work a.damage set from storage manacore:out r.damage

# 数值 -> 纯数字字符串(num_str)
data modify storage test:work a.num set from storage test:work a.damage
function test:lib/num/plain

data modify storage test:out r.damage set from storage test:work a.damage

# target 为空字符串时不能往下走: 空串依然是一个"存在的键", 只用 if data 拦不住,
# 而宏展开成 "execute as  run damage ..." 会直接报语法错。所以判断它是不是 ""。
execute unless data storage test:work a{target:""} run function test:internal/damage_go with storage test:work a
