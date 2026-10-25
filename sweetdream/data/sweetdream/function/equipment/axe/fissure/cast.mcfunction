# ============================================================
# sweetdream:equipment/axe/fissure/cast —— 崩裂 · 主动技能(右键)
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:equipment/axe/fissure(consume_item) -> rewards
# 【技能原文(必须和这里对上)】
#   魔力 150 / 冷却 40 秒。
#   原版  : "立即对自身前方 5 格的生物造成一次相当于自身基础攻击力 ×5 的伤害并形成一个
#           持续 5 秒的裂缝。之后在裂缝处的生物将每秒受到一次相当于释放者基础攻击力的伤害。"
#   超限版: "立即对自身前方 8 格的生物造成一次相当于自身基础攻击力 ×6 的伤害并形成一个
#           持续 8 秒的裂缝。之后在裂缝处的生物将每秒受到一次相当于释放者基础攻击力的
#           伤害。在裂缝上的生物将无法离开裂缝。"
# 【★ 四要素逐个落实 ★】
#   ① 触发: 右键。
#   ② 目标范围: "自身**前方** N 格" -> 每 1.5 格一个半径 1.5 的采样球串成走廊
#      (原版 3 球: 1.0/2.5/4.0 = 0~5.5 格; 超限 5 球: 再加 5.5/7.0 = 0~8.5 格, 见 dmg)。
#   ③ 次数: 立即 1 次(×5 / ×6); 裂缝**每秒 1 次**、共 5 / 8 秒(×1)。
#   ④ 时长: 裂缝持续 5(超限 8) 秒(计时 zx.fi_ft, 由 lib/second 每秒 -1)。
#   ★ 超限另加"在裂缝上的生物将无法离开裂缝" —— 见 lock_tick(每刻由 core/tick 驱动)。
# 【伤害口径】两段都吃**基础攻击力** -> attack_mul 通道。
# 【数值改哪】立即段倍率 5 / 6 与裂缝时长 5 / 8 = recalc(按 is_ol 分档);
#   采样点·半径 = dmg + area; 裂缝半径 = field_tick 的 ..3。
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
function sweetdream:lib/mana/pay
execute if data storage manacore:out r{success:0b} run tellraw @s [{"text":"魔力不足（需要 150）","color":"red"}]
execute if data storage manacore:out r{success:0b} run return fail

# ④ 起冷却 40 秒
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:fissure",cooldown_seconds:40.0,reduce:1b}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/cooldown/start

# ⑤ 判是不是超限版, 拍成 zx:work fia.ol(采样格数 / 立即段倍率 / 裂缝时长都按它分档)
function sweetdream:equipment/axe/fissure/is_ol
data modify storage zx:work fia.ol set value 0
execute if score #fi_ol zx.meta matches 1.. run data modify storage zx:work fia.ol set value 1

# ⑤-2 算两段伤害 + 裂缝时长 + 补上施法者 UUID 四整数(裂缝每秒段的击杀归属要用)
function sweetdream:equipment/axe/fissure/recalc
data modify storage zx:work fia.u0 set from entity @s UUID[0]
data modify storage zx:work fia.u1 set from entity @s UUID[1]
data modify storage zx:work fia.u2 set from entity @s UUID[2]
data modify storage zx:work fia.u3 set from entity @s UUID[3]

# ⑥ 立即对前方 N 格(原版 5 / 超限 8)的生物造成 基础攻击力 ×(5 / 6)
function sweetdream:equipment/axe/fissure/dmg with storage zx:work fia

# ⑦ 在落点(前方 2.5 格)形成一个持续 ft 秒(原版 5 / 超限 8)的裂缝
#   rotated ~ 0 = 朝向保留、俯仰归零; 这样"前方"是水平方向, 不会打到脚前地面
execute rotated ~ 0 positioned ^ ^ ^2.5 run function sweetdream:equipment/axe/fissure/field with storage zx:work fia

# ⑧ 表现
execute at @s run playsound minecraft:entity.iron_golem.attack player @a ~ ~ ~ 1.0 0.9
execute rotated ~ 0 positioned ^ ^ ^2.5 run particle minecraft:block{block_state:"minecraft:deepslate"} ~ ~0.1 ~ 1.2 0.2 1.2 0.02 20 normal
