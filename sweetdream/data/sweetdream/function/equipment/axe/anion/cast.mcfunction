# ============================================================
# sweetdream:equipment/axe/anion/cast —— 负离子: 主动技能(右键)
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:equipment/axe/anion 的奖励函数(右键消耗时, 玩家身份)
# 【文案】消耗 40 魔力 / 冷却 30 秒。使用后对自身 6 格内的随机 3 个生物
#   释放闪电，并对其造成相当于自身当前魔力值 ×0.1 的伤害。
#
# 【伤害口径 = other_mul(当前魔力)】框架的 other_mul 基数**默认就是当前魔力**
#   (见 manacore/internal/damage/use_other) —— 所以只写 {other_mul:0.1} 即可。
#   ★ 别写成 max_mana_mul(那是"最大魔力"), 文案写的是**当前**魔力。
#   ★ 登记口径表时也要标 oth:1b(见 lib/skill_mul/def 的 wchan.anion)。
#
# 【为什么先打标签、再由玩家身份统一结算】
#   /damage 要"by <施法者>"才把击杀记在玩家头上, 而选择器只能逐个 `as` 展开
#   —— 若在"目标"的身份下调 api/damage, @s 就不是玩家了, 归属丢。
#   所以照 sea_hurt_go 的定式:
#     ① 先给随机 3 只打临时标签 zx.an_hit(此时 @s 还是玩家)
#     ② 闪电逐个 `at 目标` 放(纯表现)
#     ③ 伤害由玩家身份发起, target 用范围选择器
#     ④ 用完立刻清掉临时标签
#   (这是本包"范围技能统一结算"的标准写法, 新写的 AoE 技能照抄这一段。)
#
# 【没有目标就不放】照沉渊 cast ③ 的先例: 6 格内一只可打的都没有 →
#   不扣蓝、不进冷却(只提示一行)。避免"空放"白吃 40 魔力。
#
# 【闪电用的是**原版真闪电**】和 超•负•荷(charge/bolt) / 雷鸣(thunder) 一致:
#   落点 3 格内实体各吃 5 点伤害 + 着火 —— 所以目标离你太近时你自己也会被劈到。
#   ⚠️ 若实测太痛, 把 ⑦ 换成"电火花粒子 + 雷声"(不带 summon lightning_bolt) 即可,
#      伤害不受影响(伤害一直走 ⑧ 我们自己的公式)。
# ============================================================

# ⓪ 撤销自己的进度(不撤销的话只有第一次右键会触发)
advancement revoke @s only sweetdream:equipment/axe/anion

# ① 拿 uuid
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# ② 只读检查: 冷却 + 魔力 40
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:anion",mana:40.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/skill/check
execute if data storage manacore:out r{reason:"cooldown"} run tellraw @s [{"text":"负离子冷却中，还剩 ","color":"red"},{"nbt":"r.remaining","storage":"manacore:out"},{"text":" tick","color":"red"}]
execute if data storage manacore:out r{reason:"mana"} run tellraw @s [{"text":"魔力不足(需要 40)","color":"red"}]
execute unless data storage manacore:out r{success:1b} run return fail

# ③ 有目标吗? 没有就整个不放(不扣蓝、不进冷却)
execute unless entity @e[type=!#sweetdream:no_damage,distance=0.1..6] run tellraw @s [{"text":"附近没有目标","color":"red"}]
execute unless entity @e[type=!#sweetdream:no_damage,distance=0.1..6] run return fail

# ④ 扣魔力 40
data modify storage manacore:in arg set value {uuid:"",value:40.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/mana/consume
execute if data storage manacore:out r{success:0b} run tellraw @s [{"text":"魔力不足(需要 40)","color":"red"}]
execute if data storage manacore:out r{success:0b} run return fail

# ⑤ 起冷却 30 秒
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:anion",cooldown_seconds:30.0,reduce:1b}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/cooldown/start

# ⑥ 圈目标: 6 格内随机 3 只
#   ★ sort=random 每次求值都会重挑 ⇒ 必须**先冻结成标签**, 否则后面每用一次
#     这个选择器就换一批人(闪电打 A, 伤害却落到 B 身上)。
tag @e[tag=zx.an_hit] remove zx.an_hit
execute at @s run tag @e[type=!#sweetdream:no_damage,distance=0.1..6,sort=random,limit=3] add zx.an_hit

# ⑦ 闪电(逐个 at 目标放; 原版真闪电, 见头注释的注意事项)
execute as @e[tag=zx.an_hit,distance=0..] at @s run summon minecraft:lightning_bolt ~ ~ ~

# ⑧ 伤害: 当前魔力 ×0.1(执行者仍是玩家 -> 归属正确)
data modify storage manacore:in arg set value {uuid:"",other_mul:0.1}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/damage/calc
data modify storage zx:in arg set value {target:"@e[tag=zx.an_hit,distance=0..]",damage:0.0,read:"manacore"}
function sweetdream:api/damage

# ⑨ 清临时标签(不管有没有打到都要清)
tag @e[tag=zx.an_hit,distance=0..] remove zx.an_hit

# ⑩ 表现
execute at @s run particle minecraft:electric_spark ~ ~1 ~ 1.2 0.8 1.2 0.08 40 normal
execute at @s run playsound minecraft:item.trident.thunder player @a ~ ~ ~ 0.8 1.2
