# ============================================================
# sweetdream:equipment/sword/backflow_tide/cast —— 退汐 · 主动技能(右键)
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:equipment/sword/backflow_tide(consume_item) -> rewards
# 【技能原文(必须和这里对上)】
#   ✦ 主动技能   魔力 40 · 冷却 20 秒（超限不改魔力与冷却）
#   未超限:
#   "使用后向前方 4 格内斩出一道水刃，对范围内全部生物造成一次相当于自身最大魔力值
#    ×0.08 的伤害。若命中了附有「渊海」的生物，则清除其「渊海」，将其 2 格内的其他
#    生物向外击退最多 2 格，并额外造成一次相当于自身最大魔力值 ×0.07 的伤害。"
#   超限·退汐(2026-10-23 批 K2):
#     · 范围 4 格 -> **6 格**
#     · 斩出**三道**水刃（表现; 原文仍是"造成**一次**…伤害", 所以结算只有 ⑧ 那一次）
#     · 击退最多 2 -> **3 格**
#     · 额外段 最大魔力 ×0.07 -> **×0.12**
# 【★ 四要素 ★】
#   ① 触发: 右键(consume_item)。
#   ② 范围: "前方 4 格内" -> area 里 anchored eyes + 沿朝向推到眼前 2 格 + 4×2.6×4 方盒
#      (与重溟/烈火残躯同一套"前方 N×M"口径, 见 area 文件头)。超限: 6×2.6×6。
#      渊海者的"2 格内其他生物" -> push_one 的 distance=0.01..2。
#   ③ 次数: 基础段一次(全体); 渊海那一段额外一次(全体, 见 ⑨)。
#      环绕击退 = 每个生物最多 2 格(分两次各 1 格推, 遇障碍即停)。
#   ④ 时长: 无(纯瞬间技能, 不留 marker、不占术阵位)。
# 【两段伤害走同一个通道】都是 最大魔力值 的倍数(mm):
#     基础 0.08 / 额外 0.07 —— 在 ⑥⑦ 一次算好, 之后换装也不影响这一刀。
#   ★ 因此 lib/skill_mul/def 里必须登记 wchan.backflow_tide = {mm:1b,...}。
# 【★ 2026-10-17 用户拍板的口径 ★】
#   "额外造成一次 最大魔力×0.07 的伤害" 打给谁 -> **渊海者本体 + 它 2 格内的其他生物
#   全部各吃一次**(选项"两者都吃")。实现见 dom_one ④。
# 【数值改哪】40 = skill/check 的 mana 与 ④ 的 value; 20 = ⑤ 的 cooldown_seconds;
#   0.08 = ⑥ 的 max_mana_mul; 0.07 / 0.12 = ⑦(未超限 / 超限);
#   4 格 / 6 格宽深 = area 的两行; 2 格 / 3 格击退 = push_one 的两套阶梯。
# ============================================================

# ⓪ 撤销自己的进度(自撤销型进度首行必须 revoke, 否则只触发一次)
advancement revoke @s only sweetdream:equipment/sword/backflow_tide

# ① 拿 uuid(后面所有 manacore 接口都要按 uuid 找玩家面板)
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# ② 只读检查: 冷却好没好 + 魔力 40
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:backflow_tide",mana:40.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/skill/check

execute if data storage manacore:out r{reason:"cooldown"} run tellraw @s [{"text":"退汐冷却中，还剩 ","color":"red"},{"nbt":"r.remaining","storage":"manacore:out"},{"text":" tick","color":"red"}]
execute if data storage manacore:out r{reason:"mana"} run tellraw @s [{"text":"魔力不足（需要 40）","color":"red"}]
execute unless data storage manacore:out r{success:1b} run return fail

# ③ 前方有没有目标? 一个都没有就整个不放(免白扣蓝)
#   ★ 门槛必须**盖住整片覆盖**, 否则站在走廊边上的目标会被判成"前方没人"、技能直接不响应
#     (2026-10-23 批 K1 潮痕踩过同一个坑)。
#   ⇒ 超限(6×6 盒) 与 非超限(原 4×4 盒) 各用**与 area 完全同形状**的门槛:
#     非超限沿用原来的 `positioned ^ ^ ^2 + 半径 2.2 球`; 超限改用 6 格方盒(最远角
#     √(3²+3²)=4.24, 比原球大得多, 球状门槛会漏判)。
scoreboard players set #bft_ol zx.meta 0
execute if items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["backflow_tide"],ol:"backflow_tide"}] run scoreboard players set #bft_ol zx.meta 1
execute if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["backflow_tide"],ol:"backflow_tide"}] run scoreboard players set #bft_ol zx.meta 1

execute if score #bft_ol zx.meta matches 0 rotated ~ 0 positioned ^ ^ ^2 unless entity @e[type=!#sweetdream:no_damage,distance=..2.2] run tellraw @s [{"text":"前方没有目标","color":"red"}]
execute if score #bft_ol zx.meta matches 0 rotated ~ 0 positioned ^ ^ ^2 unless entity @e[type=!#sweetdream:no_damage,distance=..2.2] run return fail
execute if score #bft_ol zx.meta matches 1 anchored eyes positioned ^ ^ ^3.0 positioned ~-3.0 ~-1.3 ~-3.0 unless entity @e[type=!#sweetdream:no_damage,dx=6.0,dy=2.6,dz=6.0] run tellraw @s [{"text":"前方没有目标","color":"red"}]
execute if score #bft_ol zx.meta matches 1 anchored eyes positioned ^ ^ ^3.0 positioned ~-3.0 ~-1.3 ~-3.0 unless entity @e[type=!#sweetdream:no_damage,dx=6.0,dy=2.6,dz=6.0] run return fail

# ④ 扣魔力 -40
data modify storage manacore:in arg set value {uuid:"",value:40.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function sweetdream:lib/mana/pay
execute if data storage manacore:out r{success:0b} run return fail

# ⑤ 记冷却 20 秒
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:backflow_tide",cooldown_seconds:20.0,reduce:1b}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/cooldown/start

# ⑥ 基础段伤害 = 自身最大魔力值 ×0.08
data modify storage manacore:in arg set value {uuid:"",max_mana_mul:0.08,independent_multiplier:1.0,custom_damage:0.0,health_ratio:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/damage/calc
data modify storage zx:work bft.dmg set from storage manacore:out r.damage

# ⑦ 额外段伤害 = 自身最大魔力值 ×0.07(清掉渊海之后那一下) / 超限 ×0.12
data modify storage manacore:in arg set value {uuid:"",max_mana_mul:0.07,independent_multiplier:1.0,custom_damage:0.0,health_ratio:0.0}
execute if score #bft_ol zx.meta matches 1 run data modify storage manacore:in arg.max_mana_mul set value 0.12
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/damage/calc
data modify storage zx:work bft.dmg2 set from storage manacore:out r.damage

# ⑧ 框"前方 4 格内" + 打基础段(顺手把命中者钉成 zx.bft_hit 给 ⑨ 用)
function sweetdream:equipment/sword/backflow_tide/area

# ⑨ 从本轮命中者里挑**最近的一个**带「渊海」的
#   ★ 原文用的是"其"(单数), 所以只取 1 个 —— 就近那个才是"水刃正面劈中"的那只。
#   ★ 先清旧标签: zx.bft_src / zx.bft_extra 是本轮的认人标记, 残留会让下一次误伤。
tag @e[tag=zx.bft_src,distance=0..] remove zx.bft_src
tag @e[tag=zx.bft_extra,distance=0..] remove zx.bft_extra
execute as @e[type=!#sweetdream:no_damage,tag=zx.bft_hit,distance=0..,tag=zx.status.yuanhai,sort=nearest,limit=1] run tag @s add zx.bft_src
execute if entity @e[tag=zx.bft_src,distance=0..] run function sweetdream:equipment/sword/backflow_tide/dom_one

# ⑩ 清理本轮标记(必须放在 dom_one 之后: 它还要用 zx.bft_src / zx.bft_hit)
tag @e[tag=zx.bft_hit,distance=0..] remove zx.bft_hit
tag @e[tag=zx.bft_src,distance=0..] remove zx.bft_src
tag @e[tag=zx.bft_extra,distance=0..] remove zx.bft_extra
tag @e[tag=zx.bft_push,distance=0..] remove zx.bft_push

# ⑪ 表现: 收刀的水花 + 提示
#   超限 = **三道水刃**: 横向 -1.6 / 0 / +1.6 各扫一道(和 6 格宽对上), 但伤害只结算 ⑧ 那一次
#   —— 原文"斩出三道水刃，对范围内全部生物造成**一次**…伤害", 三道是刀光不是三次结算。
execute rotated ~ 0 positioned ^ ^ ^3 run particle minecraft:splash ~ ~0.6 ~ 2.6 0.5 2.6 0.06 24 normal
execute rotated ~ 0 positioned ^ ^ ^3 run particle minecraft:bubble ~ ~0.5 ~ 2.2 0.4 2.2 0.03 14 normal
execute if score #bft_ol zx.meta matches 1 rotated ~ 0 positioned ^ ^ ^3 positioned ^-1.6 ^ ^ run particle minecraft:splash ~ ~0.6 ~ 0.3 0.5 0.3 0.06 12 normal
execute if score #bft_ol zx.meta matches 1 rotated ~ 0 positioned ^ ^ ^3 positioned ^1.6 ^ ^ run particle minecraft:splash ~ ~0.6 ~ 0.3 0.5 0.3 0.06 12 normal
execute if score #bft_ol zx.meta matches 1 rotated ~ 0 positioned ^ ^ ^3 positioned ^-1.6 ^ ^ run particle minecraft:bubble ~ ~0.5 ~ 0.25 0.4 0.25 0.03 8 normal
execute if score #bft_ol zx.meta matches 1 rotated ~ 0 positioned ^ ^ ^3 positioned ^1.6 ^ ^ run particle minecraft:bubble ~ ~0.5 ~ 0.25 0.4 0.25 0.03 8 normal
playsound minecraft:entity.player.attack.sweep player @a ~ ~ ~ 0.8 1.2
playsound minecraft:item.bucket.empty player @a ~ ~ ~ 0.6 1.4
