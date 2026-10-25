# ============================================================
# sweetdream:equipment/staff/cage_day/skill —— 囚昼（钻法杖 · 主动技能）
# ------------------------------------------------------------
# 【技能原文】
#   魔力 240 · 冷却 45 秒
#   "使用后选中自身 8 格内最近的一个敌对生物，使其附加「白昼梦」，持续 8 秒，
#    并对其 5 格内的全部生物造成相当于自身最大魔力值 ×0.12 的伤害。若选中的生物
#    已附有「白昼梦」，则该次伤害提高 30%，并将其「白昼梦」扩散给 5 格内最近的另外三个生物。"
# 【四要素】
#   ① 触发：潜行 + 右键（见 cast 分派）。
#   ② 目标：自身 8 格内最近的一个敌对生物（type=!#sweetdream:no_damage）。
#   ③ 次数：立即 1 次；扩散只作用在"二次命中"。
#   ④ 时长：白昼梦 8 秒。
# 【★ 8 秒怎么来的 ★】tag/mark 的 dream 是 **set 满值 15**（tag/mark_one），
#   所以施加后必须立刻把 zx.tt.dream 改写成 8 —— 这是本件唯一"绕过 mark 语义"的地方。
#   用 reset 也行，但 set 8 更明确（ttl_tick 每秒 -1，8 秒后归零自动 unmark）。
# 【伤害口径】最大魔力值 ×0.12 → 走 manacore:api/damage/calc 的 custom_damage
#   （固定值通道，照常吃加算）；"提高 30%" 走 independent_multiplier = 1.3。
# 【★ 先判目标再扣费 ★】8 格内没有敌对生物时不应白扣 240 蓝。
# ============================================================
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# ①.5 超限分档（2026-10-23 批 K8）：白昼梦 8→20 秒、伤害半径 5→8 格、
#   已有白昼梦时独立乘区 1.3→1.5、扩散改成「5 格内全部」且原已带梦者改时停 3 秒 + 25 秒。
#   ★ 计分项名一次一件事：zx.tt.dream 只管时长。
scoreboard players set #cg_ol zx.meta 0
execute if items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["cage_day"],ol:"cage_day"}] run scoreboard players set #cg_ol zx.meta 1
execute if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["cage_day"],ol:"cage_day"}] run scoreboard players set #cg_ol zx.meta 1

# ② 只读检查：冷却 + 魔力 240（超限 360）
#   ★ 先灌原版值、再被超限覆盖 —— 没敲石头时与改动前逐字一致。
scoreboard players set #cg_ml zx.meta 240
execute if score #cg_ol zx.meta matches 1 run scoreboard players set #cg_ml zx.meta 360
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:cage_day",mana:240.0}
execute store result storage manacore:in arg.mana double 1.0 run scoreboard players get #cg_ml zx.meta
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/skill/check
scoreboard players set #cg_need zx.meta 0
execute store result score #cg_need zx.meta run data get storage manacore:in arg.mana 1
execute if data storage manacore:out r{reason:"cooldown"} run tellraw @s [{"text":"囚昼冷却中，还剩 ","color":"red"},{"nbt":"r.remaining","storage":"manacore:out"},{"text":" tick","color":"red"}]
execute if data storage manacore:out r{reason:"mana"} run tellraw @s [{"text":"魔力不足（需要 ","color":"red"},{"score":{"name":"#cg_need","objective":"zx.meta"},"color":"red"},{"text":"）","color":"red"}]
execute unless data storage manacore:out r{success:1b} run return fail

# ③ 没有目标就不施放（不扣蓝、不进冷却）
execute unless entity @e[type=#sweetdream:hostile,distance=..8,sort=nearest,limit=1] run tellraw @s [{"text":"8 格内没有可指定的目标","color":"red"}]
execute unless entity @e[type=#sweetdream:hostile,distance=..8,sort=nearest,limit=1] run return fail

# ④ 扣 240（超限 360）
data modify storage manacore:in arg set value {uuid:"",value:0.0}
execute store result storage manacore:in arg.value double 1.0 run scoreboard players get #cg_ml zx.meta
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function sweetdream:lib/mana/pay
execute if data storage manacore:out r{success:0b} run return fail

# ⑤ 起冷却 45 秒
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:cage_day",cooldown_seconds:45.0,reduce:1b}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/cooldown/start

# ⑥ 记下"这一次的目标原本有没有白昼梦"
tag @e[type=#sweetdream:hostile,distance=..8,sort=nearest,limit=1] add zx.cg_tgt
scoreboard players set #cg_had zx.meta 0
execute if entity @e[tag=zx.cg_tgt,tag=zx.status.dream,limit=1] run scoreboard players set #cg_had zx.meta 1

# ⑦ 施加白昼梦（mark 满值 15 → 立刻改写：基础 8 秒 / 超限 20 秒）
function sweetdream:tag/mark {target:"@e[tag=zx.cg_tgt,limit=1]",mark:"dream"}
scoreboard players set @e[tag=zx.cg_tgt,limit=1] zx.tt.dream 8
execute if score #cg_ol zx.meta matches 1 run scoreboard players set @e[tag=zx.cg_tgt,limit=1] zx.tt.dream 20

# ⑧ 最大魔力通道；已有白昼梦时独立乘区 1.3（超限 1.5）。
data modify storage manacore:in arg set value {uuid:"",max_mana_mul:0.12,independent_multiplier:1.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute if score #cg_had zx.meta matches 1 run data modify storage manacore:in arg.independent_multiplier set value 1.3
execute if score #cg_ol zx.meta matches 1 if score #cg_had zx.meta matches 1 run data modify storage manacore:in arg.independent_multiplier set value 1.5
function manacore:api/damage/calc
data modify storage zx:work cg.dmg set from storage manacore:out r.damage

data modify storage zx:work cg.u0 set from entity @s UUID[0]
data modify storage zx:work cg.u1 set from entity @s UUID[1]
data modify storage zx:work cg.u2 set from entity @s UUID[2]
data modify storage zx:work cg.u3 set from entity @s UUID[3]

# ⑨ 对目标 5 格内全部生物结算
execute at @e[tag=zx.cg_tgt,limit=1] run function sweetdream:equipment/staff/cage_day/hit_all

# ⑩ 二次命中：把白昼梦扩散出去
#   基础版 = 5 格内最近的另外三个（各 8 秒）
#   超限版 = 5 格内**全部**；原本就带白昼梦的改时停 3 秒 + 时长延到 25 秒（见 ol_spread）
execute if score #cg_had zx.meta matches 1 if score #cg_ol zx.meta matches 0 at @e[tag=zx.cg_tgt,limit=1] run function sweetdream:equipment/staff/cage_day/spread
execute if score #cg_had zx.meta matches 1 if score #cg_ol zx.meta matches 1 at @e[tag=zx.cg_tgt,limit=1] run function sweetdream:equipment/staff/cage_day/ol_spread

execute at @e[tag=zx.cg_tgt,limit=1] run particle minecraft:dust{color:[0.95,0.9,0.55],scale:1.4} ~ ~1 ~ 0.6 0.6 0.6 0.02 24 normal
execute at @e[tag=zx.cg_tgt,limit=1] run playsound minecraft:block.beacon.activate player @a ~ ~ ~ 0.8 1.3
tag @e[tag=zx.cg_tgt] remove zx.cg_tgt
