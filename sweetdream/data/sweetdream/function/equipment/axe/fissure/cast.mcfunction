# ============================================================
# sweetdream:equipment/axe/fissure/cast —— 崩裂 · 主动技能(右键)
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:equipment/axe/fissure(consume_item) -> rewards
# 【技能原文(必须和这里对上)】
#   魔力 150 / 冷却 40 秒。
#   "立即对自身前方 5 格的生物造成一次相当于自身基础攻击力 ×5 的伤害并形成一个
#    持续 5 秒的裂缝。之后在裂缝处的生物将每秒受到一次相当于释放者基础攻击力的伤害。"
# 【★ 四要素逐个落实 ★】
#   ① 触发: 右键。
#   ② 目标范围: "自身**前方** 5 格" -> 3 个采样球(前向 1.0 / 2.5 / 4.0 格,
#      各半径 1.5)合成一条 0~5.5 格长、宽 ±1.5 的走廊(和回锋 strike 同一套做法)。
#   ③ 次数: 立即 1 次(×5); 裂缝**每秒 1 次**、共 5 秒(×1)。
#   ④ 时长: 裂缝持续 5 秒(计时 zx.fi_ft = 5, 由 lib/second 每秒 -1)。
# 【伤害口径】两段都吃**基础攻击力** -> attack_mul 通道。
# 【数值改哪】立即段倍率 5 / 每秒段倍率 1 = recalc;
#   采样点·半径 = dmg + area; 裂缝时长 = field 的 zx.fi_ft 5; 裂缝半径 = field_tick 的 ..3。
# ============================================================

# ⓪ 撤销自己的进度
advancement revoke @s only sweetdream:equipment/axe/fissure

# ① 拿 uuid
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# ② 只读检查: 冷却 + 魔力 150
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:fissure",mana:150.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/skill/check
execute if data storage manacore:out r{reason:"cooldown"} run tellraw @s [{"text":"崩裂冷却中，还剩 ","color":"red"},{"nbt":"r.remaining","storage":"manacore:out"},{"text":" tick","color":"red"}]
execute if data storage manacore:out r{reason:"mana"} run tellraw @s [{"text":"魔力不足（需要 150）","color":"red"}]
execute unless data storage manacore:out r{success:1b} run return fail

# ③ 扣魔力 150
data modify storage manacore:in arg set value {uuid:"",value:150.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/mana/consume
execute if data storage manacore:out r{success:0b} run tellraw @s [{"text":"魔力不足（需要 150）","color":"red"}]
execute if data storage manacore:out r{success:0b} run return fail

# ④ 起冷却 40 秒
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:fissure",cooldown_seconds:40.0,reduce:1b}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/cooldown/start

# ⑤ 算两段伤害 + 补上施法者 UUID 四整数(裂缝每秒段的击杀归属要用)
function sweetdream:equipment/axe/fissure/recalc
data modify storage zx:work fia.u0 set from entity @s UUID[0]
data modify storage zx:work fia.u1 set from entity @s UUID[1]
data modify storage zx:work fia.u2 set from entity @s UUID[2]
data modify storage zx:work fia.u3 set from entity @s UUID[3]

# ⑥ 立即对前方 5 格的生物造成 基础攻击力 ×5
function sweetdream:equipment/axe/fissure/dmg with storage zx:work fia

# ⑦ 在落点(前方 2.5 格)形成一个持续 5 秒的裂缝
#   rotated ~ 0 = 朝向保留、俯仰归零; 这样"前方"是水平方向, 不会打到脚前地面
execute rotated ~ 0 positioned ^ ^ ^2.5 run function sweetdream:equipment/axe/fissure/field with storage zx:work fia

# ⑧ 表现
execute at @s run playsound minecraft:entity.iron_golem.attack player @a ~ ~ ~ 1.0 0.9
execute rotated ~ 0 positioned ^ ^ ^2.5 run particle minecraft:block{block_state:"minecraft:deepslate"} ~ ~0.1 ~ 1.2 0.2 1.2 0.02 20 normal
