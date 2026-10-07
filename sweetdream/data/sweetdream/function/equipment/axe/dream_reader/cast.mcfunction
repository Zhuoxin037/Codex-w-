# ============================================================
# sweetdream:equipment/axe/dream_reader/cast —— 释梦 · 主动技能(右键)
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:equipment/axe/dream_reader(consume_item) -> rewards
# 【技能原文(必须和这里对上)】
#   魔力 200 / 冷却 40 秒。 "使用后召唤 3 个“入梦体”。"
#   “入梦体”会在离自身 10 格远或对生物造成伤害后自毁。“入梦体”会自动追踪离其最近的
#   生物并对其造成相当于释放者当前魔力值 ×0.1 的伤害，之后使其时停 3 秒并附加「白昼梦」
#   效果。（不同入梦体不会追踪同一个目标）
# 【★ 四要素逐个落实 ★】
#   ① 触发: 右键。
#   ② 目标范围: 3 个“入梦体”; 每个各自追踪"离它最近的、没被别的入梦体认领的"生物。
#   ③ 次数: 每个入梦体对目标结算 1 次(伤害 + 时停 3 秒 + 白昼梦), 然后自毁。
#   ④ 时长: 时停 3 秒(lib/timestop 60 tick); 入梦体自毁条件 = 离施法者 >10 格 或 造成伤害后
#      (另外挂 30 秒安全寿命, 防孤儿)。
# 【伤害口径】**当前魔力** ×0.1 -> other_mul(基数默认当前魔力); 在施法那一刻算好写进入梦体 NBT,
#   之后入梦体的伤害不再变化(文案的"当前魔力"取施法这一刻的值)。
# 【★ “自身”= 施法者(玩家 2026-10-07 确认) ★】10 格距离以**施法者**为圆心判。
# 【数值改哪】个数 3 = 这里的三次 pet_spawn; 距离 10 / 时停 3 秒 / 寻敌 24 格 = pet_tick;
#   伤害倍率 0.1 = 本文件; 时停秒数 = lib/timestop 的 ticks(60)。
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

# ⑤ 算伤害 = 当前魔力 ×0.1(other_mul 基数默认当前魔力)
data modify storage manacore:in arg set value {uuid:"",other_mul:0.1,independent_multiplier:1.0,custom_damage:0.0,health_ratio:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/damage/calc
data modify storage zx:work drp.dmg set from storage manacore:out r.damage

# ⑥ 施法者 UUID 四个整数(入梦体靠它反查施法者、判 10 格距离、带击杀归属)
data modify storage zx:work drp.u0 set from entity @s UUID[0]
data modify storage zx:work drp.u1 set from entity @s UUID[1]
data modify storage zx:work drp.u2 set from entity @s UUID[2]
data modify storage zx:work drp.u3 set from entity @s UUID[3]

# ⑦ 召唤 3 个入梦体(分三个稍错开的位置, 免得叠在一起)
execute positioned ~ ~ ~ run function sweetdream:equipment/axe/dream_reader/pet_spawn with storage zx:work drp
execute positioned ~0.5 ~ ~ run function sweetdream:equipment/axe/dream_reader/pet_spawn with storage zx:work drp
execute positioned ~-0.5 ~ ~ run function sweetdream:equipment/axe/dream_reader/pet_spawn with storage zx:work drp

# ⑧ 表现
execute at @s run playsound minecraft:block.beacon.activate player @a ~ ~ ~ 0.8 1.6
