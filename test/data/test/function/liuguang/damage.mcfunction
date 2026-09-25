# ============================================================
# test:liuguang/damage —— 流光技能主流程
# ------------------------------------------------------------
# 【用法】以玩家身份执行 /function test:liuguang/damage
# 【流程】拿 UUID -> 扣魔力 -> 算伤害 -> 交给 effect 打出去
# 【这里修掉的两处】
#   ① 原来写的是 ... with storage manacore:out r.damage
#      宏参数必须是一个复合标签(对象)。r.damage 是单个 double,
#      传进去会报错, 结果 effect 这个函数压根不会被调用。
#      改成传整个 r, 它里面的每个键都会成为宏变量。
#   ② 原来的选择器用了 #manacore:no_damage 这个实体类型标签。
#      manacore 包里并没有定义它(那里只有函数标签 function/event),
#      标签不存在 -> 选择器解析失败 -> 整条命令报错 -> 没有伤害。
#      改用本包自己的 #test:no_damage(在 tags/entity_type/no_damage.json)。
#   顺带把 target / type 从"给 calc 的参数"里挪走了: calc 只算伤害,
#   不认识 target, 打谁由 effect 那一步决定。
# ============================================================

# ① 先拿 uuid, 拿不到就直接结束, 不往下走
function test:uuid
execute unless data storage test:data self{ok:1b} run return fail

# ② 扣魔力
data modify storage manacore:in arg set value {value:15.0}
data modify storage manacore:in arg.uuid set from storage test:data self.uuid
function manacore:api/mana/consume
execute if data storage manacore:out r{success:0b} run return fail

# ③ 算伤害(只算不打, 结果落在 manacore:out r.damage)
data modify storage manacore:in arg set value {uuid:"",skill_multiplier:50.0,custom_damage:7000.0,independent_multiplier:1.0,health_ratio:0.0}
data modify storage manacore:in arg.uuid set from storage test:data self.uuid
function manacore:api/damage/calc

# ④ 把整个 manacore:out 当宏参数交给 effect, 由它把伤害打出去
function test:liuguang/effect with storage manacore:out r

# ⑤ 反馈
tellraw @s [{"text":"伤害: ","color":"gray"},{"nbt":"r.damage","storage":"manacore:out","color":"gold"}]
