# ============================================================
# sweetdream:equipment/staff/pour_sack/skill —— 倾囊（稀有法杖 · 主动技能）
# ------------------------------------------------------------
# 【技能原文】
#   魔力 当前魔力值的 40% · 冷却 20 秒
#   "把消耗的魔力压成一枚钉子射出，命中 10 格内最近的一个生物，造成（消耗魔力 ÷ 5）点
#    固定伤害。若本次消耗的魔力不低于 120，则再对其 2 格内的全部生物造成一半的固定伤害。"
# 【四要素】
#   ① 触发：潜行 + 右键。
#   ② 目标：10 格内最近的一个敌对生物；溅射 = 其 2 格内全部生物（含它自己）。
#   ③ 次数：立即 1 次（≥120 时多一段溅射）。
#   ④ 时长：无持续。
# 【★ 下限 60 ★】消耗 = 当前魔力 ×40%，<60 时消耗不足 24 点、伤害只有 4 点，
#   等于"免费打一发"。设计稿的实装要点明确要求：当前蓝 < 60 禁止施放。
# 【固定伤害】绕开 api/damage/calc（口径 14）：a.num ← 消耗÷5，不吃任何乘区。
# 【顺序】冷却 → 读蓝 → 判下限 → 判目标 → 扣费 → 结算。目标判定放在扣费**之前**，
#   否则空放会白白烧掉 40% 的蓝。
# ============================================================
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# ①.5 超限分档（2026-10-23 批 K8）
#   消耗 40%→50%、门槛 60→100、转化率 1 点/5 魔 → 1.5 点/5 魔、
#   溅射半径 2→5 格且「一半」→「相等」、另加 8 秒「固定伤害追伤」窗口。
scoreboard players set #ps_ol zx.meta 0
execute if items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["pour_sack"],ol:"pour_sack"}] run scoreboard players set #ps_ol zx.meta 1
execute if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["pour_sack"],ol:"pour_sack"}] run scoreboard players set #ps_ol zx.meta 1

# ② 冷却检查（魔力自己算，所以这里 mana 传 0）
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:pour_sack",mana:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/skill/check
execute if data storage manacore:out r{reason:"cooldown"} run tellraw @s [{"text":"倾囊冷却中，还剩 ","color":"red"},{"nbt":"r.remaining","storage":"manacore:out"},{"text":" tick","color":"red"}]
execute unless data storage manacore:out r{success:1b} run return fail

# ③ 读当前魔力
data modify storage manacore:in arg set value {uuid:""}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/mana/get
scoreboard players set #ps_mn zx.meta 0
execute store result score #ps_mn zx.meta run data get storage manacore:out r.value

#   ★ 门槛：基础 60 / 超限 100（先灌原版值，再被超限覆盖）
scoreboard players set #ps_min zx.meta 60
execute if score #ps_ol zx.meta matches 1 run scoreboard players set #ps_min zx.meta 100
execute if score #ps_mn zx.meta < #ps_min zx.meta run tellraw @s [{"text":"魔力不足 ","color":"red"},{"score":{"name":"#ps_min","objective":"zx.meta"},"color":"red"},{"text":"，倾囊打不出东西","color":"red"}]
execute if score #ps_mn zx.meta < #ps_min zx.meta run return fail

# ④ 消耗 = 当前魔力 ×40%（超限 ×50%）
scoreboard players set #ps_c zx.meta 0
scoreboard players operation #ps_c zx.meta = #ps_mn zx.meta
scoreboard players operation #ps_c zx.meta *= #4 zx.meta
scoreboard players operation #ps_c zx.meta *= #10 zx.meta
scoreboard players operation #ps_c zx.meta /= #100 zx.meta
execute if score #ps_ol zx.meta matches 1 run scoreboard players operation #ps_c zx.meta = #ps_mn zx.meta
execute if score #ps_ol zx.meta matches 1 run scoreboard players operation #ps_c zx.meta /= #2 zx.meta

# ⑤ 伤害 = 消耗 ÷ 5（超限 = 消耗 ×3 ÷ 10，即「每 5 点换 1.5 点」）
scoreboard players set #ps_d zx.meta 0
scoreboard players operation #ps_d zx.meta = #ps_c zx.meta
scoreboard players operation #ps_d zx.meta /= #5 zx.meta
execute if score #ps_ol zx.meta matches 1 run scoreboard players operation #ps_d zx.meta = #ps_c zx.meta
execute if score #ps_ol zx.meta matches 1 run scoreboard players operation #ps_d zx.meta *= #3 zx.meta
execute if score #ps_ol zx.meta matches 1 run scoreboard players operation #ps_d zx.meta /= #10 zx.meta

# ⑥ 没目标就不放（放在扣费之前）
execute unless entity @e[type=!#sweetdream:no_damage,distance=..10,sort=nearest,limit=1] run tellraw @s [{"text":"10 格内没有目标","color":"red"}]
execute unless entity @e[type=!#sweetdream:no_damage,distance=..10,sort=nearest,limit=1] run return fail

# ⑦ 扣费
data modify storage manacore:in arg set value {uuid:"",value:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute store result storage manacore:in arg.value double 1.0 run scoreboard players get #ps_c zx.meta
function sweetdream:lib/mana/pay
execute if data storage manacore:out r{success:0b} run return fail

# ⑧ 起冷却 20 秒
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:pour_sack",cooldown_seconds:20.0,reduce:1b}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/cooldown/start

# ⑨ 拍 UUID 与主目标位置
data modify storage zx:work ps.u0 set from entity @s UUID[0]
data modify storage zx:work ps.u1 set from entity @s UUID[1]
data modify storage zx:work ps.u2 set from entity @s UUID[2]
data modify storage zx:work ps.u3 set from entity @s UUID[3]

tag @e[type=!#sweetdream:no_damage,distance=..10,sort=nearest,limit=1] add zx.ps_tgt

# ⑩ 主目标：消耗÷5 固定伤害
execute as @e[tag=zx.ps_tgt,limit=1] at @s run function sweetdream:equipment/staff/pour_sack/main

# ⑪ 消耗 ≥120 → 溅射（基础：2 格内一半 / 超限：5 格内相等，见 splash）
execute if score #ps_c zx.meta matches 120.. at @e[tag=zx.ps_tgt,limit=1] run function sweetdream:equipment/staff/pour_sack/splash

# ⑫ ★ 超限专属：8 秒「固定伤害追伤」窗口 ★
#   原文："之后自身对生物造成固定伤害时都会额外对其造成相当于本次转化伤害的固定伤害，持续 8 秒。"
#   【怎么落地】own 的固定伤害全都走 lib/num/plain -> internal/damage/with_from（带 fixed:1b），
#     所以在 with_from 里判"这一笔是固定伤害 + 施法者的窗口还开着"就够了（钩子 ol_add）。
#   【为什么要 #ps_live 这个全局计数】with_from 里没有玩家上下文，只能按 UUID 反查；
#     没有窗口时一行 `matches 1..` 就跳过，不做反查（反查玩家全量 NBT ≈10ms/次）。
#   【#ps_at 存的是"到期时刻"而不是剩余秒数】判据只有一条 `> #now`，不用每刻减。
execute if score #ps_ol zx.meta matches 1 run scoreboard players add @s zx.ps_at 0
execute if score #ps_ol zx.meta matches 1 if score @s zx.ps_at <= #now manacore.meta run scoreboard players add #ps_live zx.meta 1
execute if score #ps_ol zx.meta matches 1 run scoreboard players operation @s zx.ps_add = #ps_d zx.meta
execute if score #ps_ol zx.meta matches 1 run scoreboard players operation @s zx.ps_at = #now manacore.meta
execute if score #ps_ol zx.meta matches 1 run scoreboard players add @s zx.ps_at 160

execute at @e[tag=zx.ps_tgt,limit=1] run particle minecraft:dust{color:[0.5,0.45,0.7],scale:1.4} ~ ~1 ~ 0.4 0.4 0.4 0.03 20 normal
execute at @e[tag=zx.ps_tgt,limit=1] run playsound minecraft:entity.arrow.shoot player @a ~ ~ ~ 0.8 0.7
tag @e[tag=zx.ps_tgt] remove zx.ps_tgt
