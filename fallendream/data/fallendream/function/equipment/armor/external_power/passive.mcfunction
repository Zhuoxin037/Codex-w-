# ============================================================
# fallendream:equipment/armor/external_power/passive —— 体外供能装置的被动 + 套装
# ------------------------------------------------------------
# 【文案上写的】
#   ① 自身生命值上限 +8
#   ② 自身魔力值为满时获得再生效果 II
#   ③ 套装(静脉泵 + 体外供能装置): 魔力上限 +120, 生命上限 +15;
#      当魔力值及生命值都为满时, 获得力量 II 和迅捷 I
#
# 【套装为什么写在体外这一份里】套装要同时看两件, 放哪边都得知道另一件;
#   按约定统一放在这里, 静脉泵那份只管自己。
# 【认装备统一用 ~ 部分匹配 + 独有标记】custom_data~{zx:["external_power"]}
#   用 = (精确匹配)会"多一段少一段就整个对不上"且不报错(踩过两次);
#   用 ~ 之后加字段不用同步改, 但标记必须是这件装备独有的, 别写公共段。
# ============================================================

# ① 拿 UUID
function fallendream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# ② 自己穿了吗 / 静脉泵穿了吗(套装要两件都在)
scoreboard players set #power_on zx.meta 0
execute if items entity @s armor.legs diamond_leggings[custom_data~{zx:["external_power"]}] run scoreboard players set #power_on zx.meta 1
scoreboard players set #pump_on zx.meta 0
execute if items entity @s armor.chest diamond_chestplate[custom_data~{zx:["intravenous_pump"]}] run scoreboard players set #pump_on zx.meta 1
scoreboard players operation #set_on zx.meta = #power_on zx.meta
scoreboard players operation #set_on zx.meta *= #pump_on zx.meta

# ③ 自己的生命上限 +8 / 超限 +16
scoreboard players set #want zx.meta 0
execute if score #power_on zx.meta matches 1 run scoreboard players set #want zx.meta 8
execute if items entity @s armor.legs *[minecraft:custom_data~{zx:["external_power"],ol:"external_power"}] run scoreboard players set #want zx.meta 16
scoreboard players operation #diff zx.meta = #want zx.meta
scoreboard players operation #diff zx.meta -= @s zx.power_hp
scoreboard players set #src zx.meta 1
execute unless score #diff zx.meta matches 0 run function fallendream:equipment/armor/external_power/apply_hp

# ④ 套装: 生命上限 +15
scoreboard players set #want zx.meta 0
execute if score #set_on zx.meta matches 1 run scoreboard players set #want zx.meta 15
scoreboard players operation #diff zx.meta = #want zx.meta
scoreboard players operation #diff zx.meta -= @s zx.set_hp
scoreboard players set #src zx.meta 2
execute unless score #diff zx.meta matches 0 run function fallendream:equipment/armor/external_power/apply_hp

# ⑤ 套装: 魔力上限 +120 (魔力上限那套账本在静脉泵那边, 直接借它的工具)
scoreboard players set #want zx.meta 0
execute if score #set_on zx.meta matches 1 run scoreboard players set #want zx.meta 120
scoreboard players operation #diff zx.meta = #want zx.meta
scoreboard players operation #diff zx.meta -= @s zx.set_mana
scoreboard players set #src zx.meta 2
execute unless score #diff zx.meta matches 0 run function fallendream:equipment/armor/intravenous_pump/apply_mana

# ⑥ 读一次魔力, 判断"满不满"
data modify storage manacore:in arg set value {uuid:""}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/mana/get
execute store result score #mana zx.meta run data get storage manacore:out r.value
execute store result score #mana_max zx.meta run data get storage manacore:out r.max
scoreboard players set #full_mana zx.meta 0
execute if score #mana_max zx.meta matches 1.. if score #mana zx.meta >= #mana_max zx.meta run scoreboard players set #full_mana zx.meta 1

# ⑥.5 超限档: 阈值从"满"放宽到 70%（#hi_mana=1 表示魔力 >70%）
scoreboard players set #ep_ol zx.meta 0
execute if items entity @s armor.legs *[minecraft:custom_data~{zx:["external_power"],ol:"external_power"}] run scoreboard players set #ep_ol zx.meta 1
scoreboard players set #ep_70 zx.meta 0
scoreboard players operation #ep_70 zx.meta = #mana_max zx.meta
scoreboard players operation #ep_70 zx.meta *= #7 zx.meta
scoreboard players operation #ep_70 zx.meta /= #10 zx.meta
scoreboard players set #hi_mana zx.meta 0
execute if score #mana_max zx.meta matches 1.. if score #mana zx.meta > #ep_70 zx.meta run scoreboard players set #hi_mana zx.meta 1

# ⑥.6 超限档: 魔力 >70% -> 最大生命 +12%（比例 modifier, 独立账本 ep_hp_p；
#   否则撤。★ 放在 any effect give 之前，账本/属性一致）
scoreboard players add @s zx.ep_hp_p 0
execute if score @s zx.ep_hp_p matches 1 unless score #hi_mana zx.meta matches 1 run attribute @s minecraft:max_health modifier remove fallendream:eqp_ep_hp
execute if score @s zx.ep_hp_p matches 1 unless score #hi_mana zx.meta matches 1 run scoreboard players set @s zx.ep_hp_p 0
execute if score @s zx.ep_hp_p matches 0 if score #ep_ol zx.meta matches 1 if score #hi_mana zx.meta matches 1 run attribute @s minecraft:max_health modifier add fallendream:eqp_ep_hp 0.12 add_multiplied_total
execute if score @s zx.ep_hp_p matches 0 if score #ep_ol zx.meta matches 1 if score #hi_mana zx.meta matches 1 run scoreboard players set @s zx.ep_hp_p 1

# ⑦ 体外: 魔力满 -> 再生 II（超限放宽到 >70%）
#   用"给 3 秒、每秒刷新"的写法, 而不是 infinite + 手动 clear ——
#   条件不成立时它自己会在 3 秒内消失; 而 effect clear 在"本来就没有"时
#   会失败, 那种失败会截断整个函数。
execute if score #power_on zx.meta matches 1 if score #full_mana zx.meta matches 1 run effect give @s minecraft:regeneration 3 1 true
execute if score #ep_ol zx.meta matches 1 if score #hi_mana zx.meta matches 1 run effect give @s minecraft:regeneration 3 1 true

# ⑦.5 超限档: 魔力 <70% -> 每秒额外恢复 8 魔力值（不 return，让 ⑧ 照常跑）
execute if score #ep_ol zx.meta matches 1 unless score #hi_mana zx.meta matches 1 run data modify storage manacore:in arg set value {uuid:"",value:8.0}
execute if score #ep_ol zx.meta matches 1 unless score #hi_mana zx.meta matches 1 run data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute if score #ep_ol zx.meta matches 1 unless score #hi_mana zx.meta matches 1 run function manacore:api/mana/add

# ⑧ 套装: 双满 -> 力量 II + 迅捷 I
execute store result score #hp zx.meta run data get entity @s Health 1
execute store result score #hp_max zx.meta run attribute @s minecraft:max_health get
execute if entity @s[tag=zx.nr_clamp] run function fallendream:lib/max_health_score
execute if entity @s[tag=zx.nr_clamp] run scoreboard players operation #hp_max zx.meta = #max_hp zx.meta
execute if entity @s[tag=zx.nr_clamp] run scoreboard players operation #hp_max zx.meta /= #1000 zx.meta
scoreboard players set #full_hp zx.meta 0
execute if score #hp_max zx.meta matches 1.. if score #hp zx.meta >= #hp_max zx.meta run scoreboard players set #full_hp zx.meta 1
execute if score #set_on zx.meta matches 1 if score #full_mana zx.meta matches 1 if score #full_hp zx.meta matches 1 run effect give @s minecraft:strength 3 1 true
execute if score #set_on zx.meta matches 1 if score #full_mana zx.meta matches 1 if score #full_hp zx.meta matches 1 run effect give @s minecraft:speed 3 0 true
