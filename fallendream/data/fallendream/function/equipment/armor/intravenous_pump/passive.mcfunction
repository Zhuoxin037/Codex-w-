# ============================================================
# fallendream:equipment/armor/intravenous_pump/passive —— 静脉泵的被动(以玩家身份)
# ------------------------------------------------------------
# 【文案上写的】① 自身魔力值上限 +120   ② 自身生命值为满时每秒恢复 3 点魔力
#
# 【怎么认"穿没穿"】execute if items entity @s armor.chest <物品>[custom_data~{...}]
#   ★ 用 ~ 做**部分匹配**, 而且只认**这件装备独有**的那一段标记:
#         custom_data~{zx:["intravenous_pump"]}
#   · 用 =(精确匹配)会出现"多写一段/少写一段就整个对不上"的静默失效(这个坑踩过两次);
#   · 换成 ~ 之后, 以后往 give 的 custom_data 里加字段, 这里不用跟着改;
#   · ⚠️ 标记必须是这件装备**独有**的 —— 写公共段(比如 "itemreplace")会让别的物品
#     也匹配上, 那才是真的串味。
#
# 【加成只能加差值】面板里每一项只是一个数, 没有"加成层"。所以用
#   zx.pump_mana 这个计分项当账本, 记"本来源已经加过多少", 换装时只补差额。
# ============================================================

# ① 拿 UUID(往面板写东西要用)
function fallendream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# ② 穿没穿
scoreboard players set #pump_on zx.meta 0
execute if items entity @s armor.chest diamond_chestplate[custom_data~{zx:["intravenous_pump"]}] run scoreboard players set #pump_on zx.meta 1
# 超限档（2026-11-22）：上限 120→160；70% 血以上每秒回 12 点，连续 8 秒后 30 点；
#   满血时魔力上限再 +12%。
scoreboard players set #pump_ol zx.meta 0
execute if items entity @s armor.chest diamond_chestplate[custom_data~{zx:["intravenous_pump"],ol:"intravenous_pump"}] run scoreboard players set #pump_ol zx.meta 1

# ③ 魔力上限：基础 +120 / 超限 +160
scoreboard players set #want zx.meta 0
execute if score #pump_on zx.meta matches 1 run scoreboard players set #want zx.meta 120
execute if score #pump_ol zx.meta matches 1 run scoreboard players set #want zx.meta 160
scoreboard players operation #diff zx.meta = #want zx.meta
scoreboard players operation #diff zx.meta -= @s zx.pump_mana
scoreboard players set #src zx.meta 1
execute unless score #diff zx.meta matches 0 run function fallendream:equipment/armor/intravenous_pump/apply_mana

# ④ 生命值满 -> 每秒回 3 点魔力
#   生命值用 scale 1 取整(Health 是浮点, 直接截断会把 27.99 当成 27, 满血误判)
execute store result score #hp zx.meta run data get entity @s Health 1
execute store result score #hp_max zx.meta run attribute @s minecraft:max_health get
execute if entity @s[tag=zx.nr_clamp] run function fallendream:lib/max_health_score
execute if entity @s[tag=zx.nr_clamp] run scoreboard players operation #hp_max zx.meta = #max_hp zx.meta
execute if entity @s[tag=zx.nr_clamp] run scoreboard players operation #hp_max zx.meta /= #1000 zx.meta
scoreboard players set #full_hp zx.meta 0
execute if score #hp_max zx.meta matches 1.. if score #hp zx.meta >= #hp_max zx.meta run scoreboard players set #full_hp zx.meta 1
# 超限的 70% 闸用 lib/hp_pct 的万分比（满血 10000 ⇒ 70% = 7000）
execute if score #pump_ol zx.meta matches 1 run function fallendream:lib/hp_pct

# ---- ④-a 基础版：满血每秒回 3 点（超限档改走 ④-b，两档互斥）----
execute if score #pump_on zx.meta matches 1 if score #full_hp zx.meta matches 1 unless score #pump_ol zx.meta matches 1 run function fallendream:equipment/armor/intravenous_pump/regen_mana

# ---- ④-b 超限：70% 血以上每秒回 12 点；连续 8 秒后 30 点 ----
#   ★ 计数只在"本秒确实在 70% 以上"时 +1，掉下去立刻清零（文案"保持"）★
scoreboard players add @s zx.ip_hi 0
execute if score #pump_ol zx.meta matches 1 if score #hp_p100 zx.meta matches ..6999 run scoreboard players set @s zx.ip_hi 0
execute if score #pump_ol zx.meta matches 1 if score #hp_p100 zx.meta matches 7000.. run scoreboard players add @s zx.ip_hi 1
execute if score #pump_ol zx.meta matches 1 if score #hp_p100 zx.meta matches 7000.. run function fallendream:equipment/armor/intravenous_pump/ol_regen

# ---- ④-c 超限满血：魔力上限额外 +12% ----
#   ★ 不能 `unless ... return 0` ★ 脱甲/掉血后必须把这份也退掉，否则 +12% 永久留着。
#   不满足条件时 #ip_want = 0，差值账本自然把它扣回去。
scoreboard players set #ip_want zx.meta 0
execute if score #pump_ol zx.meta matches 1 if score #full_hp zx.meta matches 1 run function fallendream:equipment/armor/intravenous_pump/ol_pct
scoreboard players operation #diff zx.meta = #ip_want zx.meta
scoreboard players operation #diff zx.meta -= @s zx.ip_pct
scoreboard players set #src zx.meta 3
execute unless score #diff zx.meta matches 0 run function fallendream:equipment/armor/intravenous_pump/apply_mana
