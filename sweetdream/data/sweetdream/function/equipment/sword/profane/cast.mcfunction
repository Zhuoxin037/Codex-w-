# ============================================================
# sweetdream:equipment/sword/profane/cast —— 剖心（下界剑 · 主动技能）
# ------------------------------------------------------------
# 【触发】主手右键（consume_item -> rewards）。剑没有 attack 分支，右键就是技能。
# 【技能原文(必须和这里对上)】
#   魔力 320 · 冷却 30 秒（超限不改魔力与冷却）
#   未超限:
#   "向准星方向斩出一道 2×5 的剖线，对命中的全部生物造成相当于自身基础攻击力 ×5
#    的伤害。若命中的生物附有「噬心」，则清除其「噬心」，该次伤害改为相当于自身
#    基础攻击力 ×8，且伤害额外提高 20%（独立乘区），并使命中的生物 2 格内的其他
#    生物受到该次伤害一半的伤害。每清除一个「噬心」，自身所有技能的冷却时间减少 2 秒。"
#   超限·剖心(2026-10-23 批 K2):
#     · 剖线 2×5 -> **2×8**
#     · 独立乘区 +20% -> **+50%**（1.2 -> 1.5）
#     · 2 格内其他生物: "一半的伤害" -> **"相等的伤害"**（全额复用 ×8 档）
#     · 每清一个噬心: 冷却 -2 -> **-3 秒**
#     · 新增: 本次清掉 **>5 个**噬心 -> 使**快捷栏里排在剖心前面**的武器冷却 -10 秒
# 【四要素】
#   ① 触发：右键。
#   ② 范围：未超限「2×5 剖线」= 沿朝向 5 个纵向采样点（1~5 格），每点再横向 ±0.7 一格
#      ⇒ 3×5 个判定球（每球半径 1.2），覆盖宽 2 格（±0.7 加半径 1.2 略大于 2 格，
#      取整到"打得到就打到"，不做像素级边界）。超限补到 **2×8**（采样点 1~8 格）。
#   ③ 次数：立即 1 次；清噬心的那一下额外对 2 格内其他生物 1 次。
#   ④ 时长：无持续，瞬时结算。
# 【伤害口径】两档都用 manacore:api/damage/calc 预结算（attack_mul 通道 + 独立乘区），
#   这样"基础攻击力 ×5/×8"照常吃加算池，只有 +20% 走 independent_multiplier ——
#   与设计里"独立乘区"的说法一致（不受加算稀释）。
#   ★ 半伤档 = attack_mul 4 + 独立乘区 1.2（= ×8 档的一半），不是 ×5 的一半。
# 【减冷却口径】设计写"自身所有技能"，但包内**没有可遍历的全局冷却表**
#   （manacore 的 cooldowns 是个 compound，命令列不出键；见 upgrade/api/cd_tick
#   头注释：2026-10-07 定稿"只减本武器释放的那个技能，不追踪全局冷却列表"）。
#   这里沿用同一条口径：减**剖心自己**的 30 秒冷却。清 1 个 = -2 秒。
# ============================================================
advancement revoke @s only sweetdream:equipment/sword/profane

execute unless items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["profane"]}] unless items entity @s weapon.offhand *[minecraft:custom_data~{zx:["profane"]}] run return 0

function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# ② 只读检查：冷却 + 魔力 320
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:profane",mana:320.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/skill/check
execute if data storage manacore:out r{reason:"cooldown"} run tellraw @s [{"text":"剖心冷却中，还剩 ","color":"red"},{"nbt":"r.remaining","storage":"manacore:out"},{"text":" tick","color":"red"}]
execute if data storage manacore:out r{reason:"mana"} run tellraw @s [{"text":"魔力不足（需要 320）","color":"red"}]
execute unless data storage manacore:out r{success:1b} run return fail

# ③ 扣 320
data modify storage manacore:in arg set value {uuid:"",value:320.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function sweetdream:lib/mana/pay
execute if data storage manacore:out r{success:0b} run tellraw @s [{"text":"魔力不足（需要 320）","color":"red"}]
execute if data storage manacore:out r{success:0b} run return fail

# ④ 起冷却 30 秒
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:profane",cooldown_seconds:30.0,reduce:1b}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/cooldown/start

# ⑤ 预结算三档伤害 + 拍施法者 UUID + 记"是不是超限"
#   超限·剖心(2026-10-23 批 K2):
#     · ×8 档的独立乘区 20% -> **50%**(1.2 -> 1.5)
#     · "2 格内的其他生物"从"该次伤害的**一半**"改为"**相等的伤害**"
#       ⇒ one_shixin 直接复用 pf.d8, 所以 half 这一档只有未超限时才被用到;
#         仍然照常算, 免得两个分支各存一套数值。
scoreboard players set #pf_ol zx.meta 0
execute if items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["profane"],ol:"profane"}] run scoreboard players set #pf_ol zx.meta 1
execute if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["profane"],ol:"profane"}] run scoreboard players set #pf_ol zx.meta 1

data modify storage zx:work pf set value {d5:0.0,d8:0.0,half:0.0,ol:0b,u0:0,u1:0,u2:0,u3:0}
execute if score #pf_ol zx.meta matches 1 run data modify storage zx:work pf.ol set value 1b

data modify storage manacore:in arg set value {uuid:"",attack_mul:5.0,independent_multiplier:1.0,custom_damage:0.0,health_ratio:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/damage/calc
data modify storage zx:work pf.d5 set from storage manacore:out r.damage

data modify storage manacore:in arg set value {uuid:"",attack_mul:8.0,independent_multiplier:1.2,custom_damage:0.0,health_ratio:0.0}
execute if score #pf_ol zx.meta matches 1 run data modify storage manacore:in arg.independent_multiplier set value 1.5
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/damage/calc
data modify storage zx:work pf.d8 set from storage manacore:out r.damage

data modify storage manacore:in arg set value {uuid:"",attack_mul:4.0,independent_multiplier:1.2,custom_damage:0.0,health_ratio:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/damage/calc
data modify storage zx:work pf.half set from storage manacore:out r.damage

data modify storage zx:work pf.u0 set from entity @s UUID[0]
data modify storage zx:work pf.u1 set from entity @s UUID[1]
data modify storage zx:work pf.u2 set from entity @s UUID[2]
data modify storage zx:work pf.u3 set from entity @s UUID[3]

# ⑥ 收集剖线上的生物（先全部打标记去重，再统一结算）
tag @e[tag=zx.pf_hit] remove zx.pf_hit
execute rotated ~ 0 positioned ^ ^ ^1.0 run function sweetdream:equipment/sword/profane/probe
execute rotated ~ 0 positioned ^ ^ ^2.0 run function sweetdream:equipment/sword/profane/probe
execute rotated ~ 0 positioned ^ ^ ^3.0 run function sweetdream:equipment/sword/profane/probe
execute rotated ~ 0 positioned ^ ^ ^4.0 run function sweetdream:equipment/sword/profane/probe
execute rotated ~ 0 positioned ^ ^ ^5.0 run function sweetdream:equipment/sword/profane/probe
# 超限·剖心: 剖线 2×5 -> **2×8**, 采样点补 6.0 / 7.0 / 8.0 三个
execute if score #pf_ol zx.meta matches 1 rotated ~ 0 positioned ^ ^ ^6.0 run function sweetdream:equipment/sword/profane/probe
execute if score #pf_ol zx.meta matches 1 rotated ~ 0 positioned ^ ^ ^7.0 run function sweetdream:equipment/sword/profane/probe
execute if score #pf_ol zx.meta matches 1 rotated ~ 0 positioned ^ ^ ^8.0 run function sweetdream:equipment/sword/profane/probe

# ⑦ 逐个结算（有噬心的走 ×8 分支）
scoreboard players set #pf_clear zx.meta 0
execute as @e[tag=zx.pf_hit,distance=..16] at @s run function sweetdream:equipment/sword/profane/one
tag @e[tag=zx.pf_hit] remove zx.pf_hit

# ⑧ 每清一个噬心，冷却 -2 秒 / 超限 -3 秒(每清一个)
execute if score #pf_clear zx.meta matches 1.. run function sweetdream:equipment/sword/profane/cd

# ⑧' 超限·剖心: 本次清掉 **6 个及以上**「噬心」-> 快捷栏里排在剖心**前面**的武器冷却 -10 秒
#   ★ "大于 5 个" = matches 6..(不是 5..)。
#   ★ "前面的武器" = 快捷栏 Slot 号**小于**剖心所在槽的那些格子(见 ol_prev_cd 头注释)。
execute if score #pf_ol zx.meta matches 1 if score #pf_clear zx.meta matches 6.. run function sweetdream:equipment/sword/profane/ol_prev_cd

# ⑨ 表现
execute at @s run playsound minecraft:entity.player.attack_sweep player @a ~ ~ ~ 1.0 0.8
execute at @s run playsound minecraft:entity.wither.break_block player @a ~ ~ ~ 0.6 1.4
execute rotated ~ 0 positioned ^ ^ ^2.0 run particle minecraft:sweep_attack ~ ~0.4 ~ 1.2 0.2 1.2 0 1 normal
execute rotated ~ 0 positioned ^ ^ ^4.0 run particle minecraft:dust{color:[0.35,0.05,0.1],scale:1.1} ~ ~0.4 ~ 0.9 0.2 0.9 0.02 14 normal
execute if score #pf_ol zx.meta matches 1 rotated ~ 0 positioned ^ ^ ^6.0 run particle minecraft:dust{color:[0.35,0.05,0.1],scale:1.0} ~ ~0.4 ~ 0.8 0.2 0.8 0.02 12 normal
execute if score #pf_ol zx.meta matches 1 rotated ~ 0 positioned ^ ^ ^8.0 run particle minecraft:sweep_attack ~ ~0.4 ~ 0.6 0.2 0.6 0 1 normal
