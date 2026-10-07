# ============================================================
# sweetdream:equipment/sword/verdict/cast —— 神裁 · 主动技能(右键)
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:equipment/sword/verdict(consume_item) -> rewards
# 【技能原文(必须和这里对上)】
#   主动: 魔力 380 / 冷却 10 秒。
#   "使自身 6 格内的至多 2 个生物受到相当于自身最大魔力值 ×0.1 的伤害，之后在
#    受到伤害的生物处生成一个持续 3 秒的半径 2 格的领域，在领域中的生物每秒
#    受到一次相当于施放者基础攻击力 ×3 的伤害。"
# 【★ 四要素逐个落实 ★】
#   ① 触发: 右键。
#   ② 目标范围: "自身 6 格内的**至多 2 个**生物"(sort=nearest,limit=2);
#      领域: 在**受到伤害的生物处**生成(marker 实体), 半径 2 格。
#   ③ 次数: 主动伤害一次; 领域**每秒一次**, 共 3 次。
#   ④ 时长: 领域持续 3 秒(marker 上 zx.vd_ft = 3, lib/second 每秒 -1, 归零 kill)。
# 【两段伤害走不同通道】先 最大魔力 ×0.1(mm); 领域 基础攻击力 ×3(atk)。
#   领域的伤害值在**施放那一刻算好**写进 marker NBT(施放者是施放者, 之后他死了也一样打)。
# 【数值改哪】距离 6 / 目标数 2 = 选择器与 limit; 倍率 0.1 = max_mana_mul; 领域倍率 3 = attack_mul;
#   领域时长 3 秒 = field_one 的 zx.vd_ft; 领域半径 2 = field_tick 的 distance=..2。
# ============================================================

# ⓪ 撤销自己的进度
advancement revoke @s only sweetdream:equipment/sword/verdict

# ① 拿 uuid
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# ② 只读检查: 冷却好没好 + 魔力 380
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:verdict",mana:380.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/skill/check

execute if data storage manacore:out r{reason:"cooldown"} run tellraw @s [{"text":"神裁冷却中，还剩 ","color":"red"},{"nbt":"r.remaining","storage":"manacore:out"},{"text":" tick","color":"red"}]
execute if data storage manacore:out r{reason:"mana"} run tellraw @s [{"text":"魔力不足（需要 380）","color":"red"}]
execute unless data storage manacore:out r{success:1b} run return fail

# ③ 有目标吗? 6 格内一个都没有就整个不放
execute unless entity @e[type=!#sweetdream:no_damage,distance=0.1..6] run tellraw @s [{"text":"附近没有目标","color":"red"}]
execute unless entity @e[type=!#sweetdream:no_damage,distance=0.1..6] run return fail

# ④ 扣魔力 -380
data modify storage manacore:in arg set value {uuid:"",value:380.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/mana/consume
execute if data storage manacore:out r{success:0b} run return fail

# ⑤ 记冷却 10 秒
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:verdict",cooldown_seconds:10.0,reduce:1b}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/cooldown/start

# ⑥ 选至多 2 个: 6 格内就近取 2 个, 钉成 zx.vd_mark(避免 @e 每步重挑)
tag @e[tag=zx.vd_mark] remove zx.vd_mark
execute as @e[type=!#sweetdream:no_damage,distance=0.1..6,sort=nearest,limit=2] run tag @s add zx.vd_mark

# ⑦ 第一段伤害: 最大魔力 ×0.1(mm)
data modify storage manacore:in arg set value {uuid:"",max_mana_mul:0.1,independent_multiplier:1.0,custom_damage:0.0,health_ratio:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/damage/calc
data modify storage zx:in arg set value {target:"@e[tag=zx.vd_mark,distance=0..]",damage:0.0}
data modify storage zx:in arg.damage set from storage manacore:out r.damage
execute at @s run function sweetdream:api/damage

# ⑧ 领域伤害(先算好): 基础攻击力 ×3
data modify storage manacore:in arg set value {uuid:"",attack_mul:3.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/damage/calc
data modify storage zx:work vdf.dmg set from storage manacore:out r.damage

# ⑨ 在"受到伤害的生物处"生成领域(宏层: NBT 里要拼施放者 UUID 的四个整数)
data modify storage zx:work vdf.uuid set from storage zx:data self.uuid
function sweetdream:equipment/sword/verdict/field with storage zx:work vdf

# ⑩ 清理临时标签
tag @e[tag=zx.vd_mark] remove zx.vd_mark
