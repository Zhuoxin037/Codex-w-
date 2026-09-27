# ============================================================
# sweetdream:api/damage —— 把数值打成伤害(公开接口)
# ------------------------------------------------------------
# 【调用模板】
#   data modify storage zx:in arg set value {target:"@e[type=!#sweetdream:no_damage,distance=..3]", damage:37.5}
#   function sweetdream:api/damage
#   /data get storage zx:out r.applied     -> 1b 说明命令执行了
#   /data get storage zx:out r.damage      -> 实际用的伤害值
# 【入参】(全部写进 sweetdream:in arg, 没写的用默认值)
#   target  : 选择器字符串(必填, 留空则整个接口什么都不做)
#   damage  : 伤害数值, 默认 0.0
#   type    : 伤害类型, 默认 minecraft:player_attack
#             —— 按玩家平砍结算, 吃护甲和保护附魔
#             想穿甲(无视护甲)就填 minecraft:magic
# 【关于伤害类型】1.21.5 原版没有"无视受伤无敌帧"的伤害类型标签, 自定义类型
#   也没注册进去, 所以这里默认用原版类型; 多段伤害撞无敌帧的问题见 README。
#   read    : 填 "manacore" 时, 忽略 damage, 直接从 manacore:out r.damage 取
#             —— 这就是"把 manacore 算出来的伤害用进 /damage"的开关
# 【target 可以是范围选择器】/damage 本身只收单个实体, 但本接口内部用
#   execute as 逐个处理, 所以写 "@e[type=!#sweetdream:no_damage,distance=..3]" 是对的。
# 【为什么要先 set value 再 merge】宏参数不能缺字段, 而且 work 节点是复用
#   的, 不覆盖就会沿用上一次调用的旧值。
# ============================================================

data modify storage zx:work a set value {target:"",damage:0.0,type:"minecraft:player_attack",read:""}
data modify storage zx:work a merge from storage zx:in arg

# 出参先复位, 免得读到上一次调用的残留值
data modify storage zx:out r.applied set value 0b
data modify storage zx:out r.damage set value 0.0

# 可选: 从 manacore 的出口直接取伤害。
# 加一层 if data 保护: manacore 没装时这个存储不存在, 不加保护会报错中断。
execute if data storage zx:work a{read:"manacore"} if data storage manacore:out r.damage run data modify storage zx:work a.damage set from storage manacore:out r.damage

# 数值 -> 纯数字字符串(num_str)
data modify storage zx:work a.num set from storage zx:work a.damage
function sweetdream:lib/num/plain

data modify storage zx:out r.damage set from storage zx:work a.damage

# target 为空字符串时不能往下走: 空串依然是一个"存在的键", 只用 if data 拦不住,
# 而宏展开成 "execute as  run damage ..." 会直接报语法错。所以判断它是不是 ""。
execute unless data storage zx:work a{target:""} run function sweetdream:internal/damage/go with storage zx:work a
