# ============================================================
# sweetdream:equipment/axe/dream_reader/cast —— 释梦 · 主动技能(右键)
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:equipment/axe/dream_reader(consume_item) -> rewards
# 【技能原文(必须和这里对上)】
#   基础: 魔力 200 / 冷却 40 秒。 "使用后召唤 3 个“入梦体”。"
#     “入梦体”会在离自身 10 格远或对生物造成伤害后自毁。“入梦体”会自动追踪离其最近的
#     生物并对其造成相当于释放者当前魔力值 ×0.1 的伤害，之后使其时停 2 秒并附加「白昼梦」
#     效果。（不同入梦体不会追踪同一个目标）
#   超限(第三十三批, 2026-10-10): 只改入梦体那一串 ——
#     “入梦体”会在离**施法者 18 格**远或**施法者 12 格内没有未攻击过的目标**后自毁。
#     伤害 = 当前魔力 ×**0.12**，之后使其时停 **2 秒**并附加「白昼梦」。
#     ★ 个数 3 / 魔力 200 / 冷却 40 秒 **都不变**。
# 【★ 四要素逐个落实 ★】
#   ① 触发: 右键。
#   ② 目标范围: 3 个“入梦体”; 每个各自追踪"离它最近的、没被别的入梦体占的"生物。
#      ★ 认领后**按 uuid 绑死**(data.zx.tg), 之后不再换目标 —— 这才是文案"不同入梦体不会
#        追踪同一个目标"的实现。目标不够时(比如只有 1 只却召了 3 个)多的原地悬停。
#      ★ 2026-10-08 修: 老实现用通用标记 `@e[tag=zx.dr_claim,sort=nearest]` 找目标,
#        只要有**任何**一只被认领, 所有入梦体都会朝"自己最近的那只"飞 => 全追同一只。
#   ③ 次数: 基础版每个入梦体对目标结算 1 次(伤害 + 时停 2 秒 + 白昼梦), 然后自毁;
#      ★ 超限版**不自毁** —— 打完记进"已打过"(zx.dr_done), 摘掉绑定去追下一个没打过的,
#        直到"施法者 12 格内没有未攻击过的目标"或飞出 18 格才自毁。
#   ④ 时长: 时停 2 秒(lib/timestop 40 tick; 基础版与超限版同, 用户 2026-10-10 把基础版从 3 秒改过来);
#      入梦体自毁条件 = 离施法者 >10 格(超限 18) 或 造成伤害后(仅基础版)
#      (另外挂 30 秒安全寿命, 防孤儿)。
# 【超限怎么传下去】离弦式快照同理: 施法那刻拍 `#dr_ol`, 随 `zx:work drp.ol` 进
#   入梦体 NBT, 并给它打 tag `zx.dr_ol`(入梦体侧全靠这个 tag 分支)。
# 【★ “自身”= 施法者(玩家 2026-10-07 确认) ★】10 / 18 / 12 格距离**都以施法者**为圆心判。
# 【数值改哪】个数 3 = 这里的三次 pet_spawn; 距离 10(超限 18) / 判空 12 格 = pet_tick;
#   伤害倍率 0.1(超限 0.12) = 本文件; 时停秒数 = lib/timestop 的 ticks(40, 基础版与超限版同)。
# ============================================================

# ⓪ 撤销自己的进度
advancement revoke @s only sweetdream:equipment/axe/dream_reader

# ① 拿 uuid
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# ② 只读检查: 冷却 + 魔力 200
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:dream_reader",mana:200.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/skill/check
execute if data storage manacore:out r{reason:"cooldown"} run tellraw @s [{"text":"释梦冷却中，还剩 ","color":"red"},{"nbt":"r.remaining","storage":"manacore:out"},{"text":" tick","color":"red"}]
execute if data storage manacore:out r{reason:"mana"} run tellraw @s [{"text":"魔力不足（需要 200）","color":"red"}]
execute unless data storage manacore:out r{success:1b} run return fail

# ③ 扣魔力 200
data modify storage manacore:in arg set value {uuid:"",value:200.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/mana/consume
execute if data storage manacore:out r{success:0b} run tellraw @s [{"text":"魔力不足（需要 200）","color":"red"}]
execute if data storage manacore:out r{success:0b} run return fail

# ④ 起冷却 40 秒
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:dream_reader",cooldown_seconds:40.0,reduce:1b}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/cooldown/start

# ⑤ 算伤害 = 当前魔力 ×0.1(超限 ×0.12) —— other_mul 基数默认当前魔力
#   ★ 先拍"这次施法是不是超限版": 主手或副手那件带 ol:"dream_reader" 就是。
data modify storage zx:work drp set value {dmg:0.0,ol:0b,u0:0,u1:0,u2:0,u3:0}
scoreboard players set #dr_ol zx.meta 0
execute if items entity @s weapon.mainhand *[custom_data~{zx:["dream_reader"],ol:"dream_reader"}] run scoreboard players set #dr_ol zx.meta 1
execute if items entity @s weapon.offhand *[custom_data~{zx:["dream_reader"],ol:"dream_reader"}] run scoreboard players set #dr_ol zx.meta 1
execute if score #dr_ol zx.meta matches 0 run data modify storage manacore:in arg set value {uuid:"",other_mul:0.1,independent_multiplier:1.0,custom_damage:0.0,health_ratio:0.0}
execute if score #dr_ol zx.meta matches 1 run data modify storage manacore:in arg set value {uuid:"",other_mul:0.12,independent_multiplier:1.0,custom_damage:0.0,health_ratio:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/damage/calc
data modify storage zx:work drp.dmg set from storage manacore:out r.damage
execute store result storage zx:work drp.ol byte 1 run scoreboard players get #dr_ol zx.meta

# ⑥ 施法者 UUID 四个整数(入梦体靠它反查施法者、判 10 格距离、带击杀归属)
data modify storage zx:work drp.u0 set from entity @s UUID[0]
data modify storage zx:work drp.u1 set from entity @s UUID[1]
data modify storage zx:work drp.u2 set from entity @s UUID[2]
data modify storage zx:work drp.u3 set from entity @s UUID[3]

# ⑥' 清上一轮的"已打过"名单(只超限版用得上)
#   ★ 名单是打在**生物**上的 tag `zx.dr_done`, 入梦体自己会消失、tag 不会 ⇒ 必须有人清。
#   ★ 只在"场上已经没有入梦体"时才清: 多玩家同时开着技能时不清, 免得把别人的名单抹了
#     (那种情况下这一波最多是重复打同一只, 不会出错)。裸 @e 是**故意**的 —— 要全维度清。
execute unless entity @e[tag=zx.dr_pet,limit=1] run tag @e remove zx.dr_done

# ⑦ 召唤 3 个入梦体(分三个稍错开的位置, 免得叠在一起)
execute positioned ~ ~ ~ run function sweetdream:equipment/axe/dream_reader/pet_spawn with storage zx:work drp
execute positioned ~0.5 ~ ~ run function sweetdream:equipment/axe/dream_reader/pet_spawn with storage zx:work drp
execute positioned ~-0.5 ~ ~ run function sweetdream:equipment/axe/dream_reader/pet_spawn with storage zx:work drp

# ⑧ 表现
execute at @s run playsound minecraft:block.beacon.activate player @a ~ ~ ~ 0.8 1.6
