# ============================================================
# api/skill/cast —— 统一技能释放入口(推荐使用)
# ------------------------------------------------------------
# 【一次调用完成】
#   冷却检查 -> 魔力扣除 -> 开始冷却 -> 伤害计算 -> 施加伤害 -> 抛技能事件
# 【调用模板】以火球术为例(假设已经拿到施法者 UUID):
#   data modify storage manacore:in arg set value {
#       uuid:"<施法者UUID>", skill:"mypack:fireball",
#       mana:20.0, cooldown_seconds:3.0,
#       skill_multiplier:2.0, independent_multiplier:1.0, custom_damage:6.0,
#       target:"@e[tag=mana_target,distance=..8,limit=1]"}
#   function manacore:api/skill/cast
#   /execute if data storage manacore:out r {success:1b} run <放成功的表现>
# 【字段速查】
#   uuid/skill             必填
#   mana                   魔力消耗(consume:0b 时忽略)
#   cooldown / cooldown_seconds  冷却(tick 优先, 秒自动 x20)
#   reduce                 是否吃冷却缩减, 默认 1b
#   consume                是否扣魔力, 默认 1b
#   base_attack            -1 = 用面板
#   skill_multiplier / independent_multiplier / custom_damage / health_ratio
#   target                 目标选择器, 省略=只算伤害不打
#   type                   伤害类型, 默认 minecraft:magic
#   from                   攻击者选择器, 省略自动推导
# 【出参】out.success / out.reason("cooldown"/"mana"/"ok")
#         out.damage / out.remaining(冷却剩余)
# 【失败时什么都不会发生】不会扣蓝、不会进冷却 —— 因为这两步都在
#   out.success 判定之后。
# ============================================================
# 入参: manacore:in {uuid, skill, mana, cooldown|cooldown_seconds, reduce, consume,
#                     base_attack, skill_multiplier, independent_multiplier, custom_damage, health_ratio,
#                     target(可选), type(可选), from(可选)}
# 出参: manacore:out.success / out.reason / out.damage / out.remaining
data modify storage manacore:work a set value {uuid:"",skill:"",mana:0.0,cooldown:0,cooldown_seconds:0.0,reduce:1b,consume:1b,base_attack:-1.0,skill_multiplier:1.0,independent_multiplier:1.0,custom_damage:0.0,health_ratio:0.0,type:"minecraft:magic"}
data modify storage manacore:work a merge from storage manacore:in arg
data modify storage manacore:out r.success set value 0b
data modify storage manacore:out r.reason set value ""
function manacore:api/player/ensure
execute if data storage manacore:work a.uuid if data storage manacore:work a.skill run function manacore:internal/skill/cast with storage manacore:work a
