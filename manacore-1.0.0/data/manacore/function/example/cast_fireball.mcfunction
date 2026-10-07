# ============================================================
# example/cast_fireball —— 示例: 用统一技能接口放一个火球
# ------------------------------------------------------------
# 【怎么用】以玩家身份执行: /function manacore:example/cast_fireball
# 【这个文件是教学示例, 可以整个 example 目录删掉】
# 【它演示了什么】
#   ① 怎么拿到自己的 UUID(前缀包没有名字, 必须走槽位索引反查)
#   ② 怎么组装 skill/cast 的参数
#   ③ 怎么根据 out.success / out.reason 做后续表现
# 【注意】这个示例的目标选择器是 @e[tag=mana_target]; 想测试请先给一个
#   实体打上标签: /tag @e[type=zombie,limit=1] add mana_target
# ============================================================

# ① 反查自己的 UUID(公开接口, 结果在 manacore:out.uuid)
function manacore:api/player/self_uuid

# ② 组装技能参数(魔力 20, 冷却 3 秒, 基础攻击力倍率 2, 固定伤害 6)
data modify storage manacore:in arg set value {skill:"example:fireball",mana:20.0,cooldown_seconds:3.0,attack_mul:2.0,independent_multiplier:1.0,custom_damage:6.0,target:"@e[tag=mana_target,distance=..8,limit=1]"}
data modify storage manacore:in arg.uuid set from storage manacore:out r.uuid

# ③ 交给框架: 冷却检查 -> 扣蓝 -> 记冷却 -> 算伤害 -> 打伤害 -> 抛事件
function manacore:api/skill/cast

# ④ 结果处理
execute if data storage manacore:out r{success:1b} run tellraw @s {"text":"火球命中!","color":"gold"}
execute if data storage manacore:out r{reason:"cooldown"} run tellraw @s {"text":"技能冷却中, 无法释放","color":"red"}
execute if data storage manacore:out r{reason:"mana"} run tellraw @s {"text":"魔力不足","color":"red"}

# ⑤ 打出来多少伤害(便于核对公式)
tellraw @s [{"text":"本次伤害: ","color":"gray"},{"nbt":"r.damage","storage":"manacore:out"}]
