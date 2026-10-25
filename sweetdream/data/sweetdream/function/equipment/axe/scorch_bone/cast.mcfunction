# ============================================================
# sweetdream:equipment/axe/scorch_bone/cast —— 焦骨 · 主动技能(右键)
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:equipment/axe/scorch_bone(consume_item) -> rewards
# 【主动原文(必须和这里对上)】
#   魔力 160 / 冷却 28 秒。
#   "攻击6格内最近一个目标，造成相当于自身基础攻击力×5的伤害，并对其周围2格造成
#    最大魔力×0.05伤害。若主目标拥有「流火」，则将其「流火」转化为「夜火」，并返还
#    40魔力；若主目标原本已经拥有「夜火」，则改为将范围伤害提高至相当于自身最大魔力×0.1。"
# 【四要素】① 触发 = 右键; ② 范围 = 6 格内**最近一只**(主目标) -> 其 2 格内的全部(范围段);
#   ③ 次数 = 1; ④ 时长 = —(瞬发)。
# 【★ 分档口径 ★】先看「夜火」(更强的那一档): 有 -> 范围提到 ×0.1, **不改标签、不返魔力**;
#   否则若有「流火」-> 转「夜火」+ 返 40 魔力(范围仍 ×0.05)。两档互斥(原文的"改为")。
# 【★ 没目标就整个不放 ★】不扣蓝、不进冷却。
# 【★ 顺序: 先定档/转标签, 再算范围伤害 ★】否则"这一发就把主目标的流火转成夜火"会让
#   同一发的范围伤害吃到 0.1 —— 原文的"原本已经拥有"明确指**施法前**的状态。
# ============================================================

# ⓪ 撤销自己的进度
advancement revoke @s only sweetdream:equipment/axe/scorch_bone

# ⓪.6 这一次是不是超限版(亲手/副手那把带 ol:"scorch_bone")
scoreboard players set @s zx.scb_ol 0
execute if items entity @s weapon.mainhand diamond_axe[custom_data~{ol:"scorch_bone"}] run scoreboard players set @s zx.scb_ol 1
execute if items entity @s weapon.offhand diamond_axe[custom_data~{ol:"scorch_bone"}] run scoreboard players set @s zx.scb_ol 1

# ① 拿 uuid
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# ② 找 6 格内最近一只(主目标)
tag @e[tag=zx.sc_t] remove zx.sc_t
execute at @s run tag @e[type=!#sweetdream:no_damage,distance=..6,sort=nearest,limit=1] add zx.sc_t
execute unless entity @e[tag=zx.sc_t,distance=0..,limit=1] run tellraw @s [{"text":"6 格内没有目标","color":"red"}]
execute unless entity @e[tag=zx.sc_t,distance=0..,limit=1] run return fail

# ③ 只读检查: 冷却 + 魔力 160 / 超限 260
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:scorch_bone",mana:160.0}
execute if score @s zx.scb_ol matches 1 run data modify storage manacore:in arg.mana set value 260.0
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/skill/check
execute if data storage manacore:out r{reason:"cooldown"} run tellraw @s [{"text":"焦骨冷却中，还剩 ","color":"red"},{"nbt":"r.remaining","storage":"manacore:out"},{"text":" tick","color":"red"}]
execute if score @s zx.scb_ol matches 0 if data storage manacore:out r{reason:"mana"} run tellraw @s [{"text":"魔力不足（需要 160）","color":"red"}]
execute if score @s zx.scb_ol matches 1 if data storage manacore:out r{reason:"mana"} run tellraw @s [{"text":"魔力不足（需要 260）","color":"red"}]
execute unless data storage manacore:out r{success:1b} run return fail

# ④ 扣魔力 160 / 超限 260
data modify storage manacore:in arg set value {uuid:"",value:160.0}
execute if score @s zx.scb_ol matches 1 run data modify storage manacore:in arg.value set value 260.0
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function sweetdream:lib/mana/pay
execute if data storage manacore:out r{success:0b} run return fail

# ⑤ 起冷却 28 秒 / 超限 25 秒
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:scorch_bone",cooldown_seconds:28.0,reduce:1b}
execute if score @s zx.scb_ol matches 1 run data modify storage manacore:in arg.cooldown_seconds set value 25.0
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/cooldown/start

# ⑥ 定档(按施法前的状态) + 流火转夜火
#   #sc_mode: 0 = 主目标啥都没有 / 1 = 有「流火」 / 2 = 已有「夜火」(更强的那一档)
#   #sc_a   : 范围倍率的千分比 —— 普通 50(×0.05) / 100(×0.1); 超限 80(×0.08) / 120(×0.12)
scoreboard players set #sc_mode zx.meta 0
execute if entity @e[tag=zx.sc_t,distance=0..,limit=1,tag=zx.status.yehuo] run scoreboard players set #sc_mode zx.meta 2
execute unless score #sc_mode zx.meta matches 2 if entity @e[tag=zx.sc_t,distance=0..,limit=1,tag=zx.status.liuhuo] run scoreboard players set #sc_mode zx.meta 1
scoreboard players set #sc_a zx.meta 50
execute if score @s zx.scb_ol matches 1 run scoreboard players set #sc_a zx.meta 80
execute if score #sc_mode zx.meta matches 2 run scoreboard players set #sc_a zx.meta 100
execute if score @s zx.scb_ol matches 1 if score #sc_mode zx.meta matches 2 run scoreboard players set #sc_a zx.meta 120
#   流火档: 先摘流火再贴夜火 + 返魔力(普通 40 / 超限 130)
execute if score #sc_mode zx.meta matches 1 run function sweetdream:equipment/axe/scorch_bone/convert
#   夜火档: 普通版不返还; 超限版返 80%(260×0.8 = 208), 且溅射已提到 ×0.12
execute if score @s zx.scb_ol matches 1 if score #sc_mode zx.meta matches 2 run function sweetdream:equipment/axe/scorch_bone/ol_refund

# ⑦ 主目标: 基础攻击力 ×5 / 超限 ×8
data modify storage manacore:in arg set value {uuid:"",attack_mul:5.0}
execute if score @s zx.scb_ol matches 1 run data modify storage manacore:in arg.attack_mul set value 8.0
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/damage/calc
data modify storage zx:in arg set value {target:"@e[tag=zx.sc_t,distance=0..]",damage:0.0}
data modify storage zx:in arg.damage set from storage manacore:out r.damage
function sweetdream:api/damage

# ⑧ 范围: 主目标 N 格内全部(普通 2 / 超限 4), 最大魔力 ×(0.05|0.1) / 超限 ×(0.08|0.12)
tag @e[tag=zx.sc_hit] remove zx.sc_hit
execute if score @s zx.scb_ol matches 0 at @e[tag=zx.sc_t,distance=0..,limit=1] run tag @e[type=!#sweetdream:no_damage,distance=..2] add zx.sc_hit
execute if score @s zx.scb_ol matches 1 at @e[tag=zx.sc_t,distance=0..,limit=1] run tag @e[type=!#sweetdream:no_damage,distance=..4] add zx.sc_hit
data modify storage manacore:in arg set value {uuid:"",max_mana_mul:0.05}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute store result storage manacore:in arg.max_mana_mul double 0.001 run scoreboard players get #sc_a zx.meta
function manacore:api/damage/calc
data modify storage zx:in arg set value {target:"@e[tag=zx.sc_hit,distance=0..]",damage:0.0}
data modify storage zx:in arg.damage set from storage manacore:out r.damage
function sweetdream:api/damage

# ⑧.5 超限: 范围伤害同时「附加流火」
#   ★ 排除已经带「夜火」的 —— 文字顺序是"打伤害并附加流火, 若原本有流火则转夜火";
#     主目标若已在上一步由流火转成夜火, 再补流火就会两个标签并存(摘的时候只摘一个)。
#   ★ **不能带 limit=1**: tag/mark 内部是 `as $(target)` 遍历, 带 limit 就只贴一只。
#   ★ 走统一入口 tag/mark(它会顺手挂 -20% 护甲修饰符, 和别的施加流火的路径一致;
#     重复施加是"刷新"不是叠加)。
tag @e[tag=zx.sc_fire] remove zx.sc_fire
execute as @e[tag=zx.sc_hit,distance=0..] unless entity @s[tag=zx.status.yehuo] run tag @s add zx.sc_fire
execute if score @s zx.scb_ol matches 1 if entity @e[tag=zx.sc_fire,distance=0..,limit=1] run function sweetdream:tag/mark {target:"@e[tag=zx.sc_fire,distance=0..]",mark:"liuhuo"}
tag @e[tag=zx.sc_fire,distance=0..] remove zx.sc_fire

# ⑨ 表现
execute at @e[tag=zx.sc_t,distance=0..,limit=1] run particle minecraft:flame ~ ~0.5 ~ 1.2 0.4 1.2 0.02 24 normal
execute at @e[tag=zx.sc_t,distance=0..,limit=1] run particle minecraft:lava ~ ~0.3 ~ 0.8 0.2 0.8 0 12 normal
execute at @s run playsound minecraft:item.firecharge.use player @a ~ ~ ~ 0.9 0.9
execute at @e[tag=zx.sc_t,distance=0..,limit=1] run playsound minecraft:block.fire.extinguish player @a ~ ~ ~ 0.7 1.3

# ⑩ 收尾
tag @e[tag=zx.sc_hit] remove zx.sc_hit
tag @e[tag=zx.sc_t] remove zx.sc_t
