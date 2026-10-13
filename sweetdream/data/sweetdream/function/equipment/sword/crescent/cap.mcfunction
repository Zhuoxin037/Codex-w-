# ============================================================
# sweetdream:equipment/sword/crescent/cap —— 拍"被冻结名单"快照 + 算加成%
# ------------------------------------------------------------
# 【谁调用它】crescent/cast ④(宏 {uuid})   【执行者】施法者玩家
# 【干什么】
#   ① 先把这份名单清空: zx:freeze p."<uuid>".s0..s8 = ""(每格一个快捷栏格)
#   ② 9 个快捷栏格逐个看: 该格有 skill 且不是缺月自己 且**正在冷却** ->
#      把 skill id 写进 sN, 并把它的剩余 tick 累加进 #cr_tt
#   ③ @s zx.cr_b = #cr_tt / 20 (= "冻结了多少秒"), 上限 150
# 【★ 为什么"拍快照"而不是窗内现读 ★】原文冻结的是"当前快捷栏内所有技能";
#   窗内玩家换手/挪格会让"现读"读到别的东西 ⇒ 名单必须在施法那一刻定死(与
#   lib/atk_charge 的"同刻只算一次"、时停的"先抄快照"同一个道理)。
# 【★ 不能在这里用 return ★】return 会**整段退出**本函数, 后面 8 个槽就不看了;
#   所以每个槽的"跳过"都写在后续行的条件里, 不用 return。
# ============================================================

# ① 名单清空
$data modify storage zx:freeze p."$(uuid)" set value {s0:"",s1:"",s2:"",s3:"",s4:"",s5:"",s6:"",s7:"",s8:""}

# ---- 槽 0 ----
data remove storage zx:work cr.s
execute if data entity @s Inventory[{Slot:0b}].components."minecraft:custom_data".skill run data modify storage zx:work cr.s set from entity @s Inventory[{Slot:0b}].components."minecraft:custom_data".skill
scoreboard players set #cr_e zx.meta 0
execute if data storage zx:work cr.s unless data storage zx:work cr{s:"sweetdream:crescent"} run scoreboard players set #cr_e zx.meta 1
$data modify storage manacore:in arg set value {uuid:"$(uuid)",skill:""}
execute if score #cr_e zx.meta matches 1 run data modify storage manacore:in arg.skill set from storage zx:work cr.s
execute if score #cr_e zx.meta matches 1 run function manacore:api/cooldown/get
execute if score #cr_e zx.meta matches 1 unless data storage manacore:out r{ready:0b} run scoreboard players set #cr_e zx.meta 0
$execute if score #cr_e zx.meta matches 1 run data modify storage zx:freeze p."$(uuid)".s0 set from storage zx:work cr.s
scoreboard players set #cr_rem zx.meta 0
execute if score #cr_e zx.meta matches 1 store result score #cr_rem zx.meta run data get storage manacore:out r.remaining
execute if score #cr_e zx.meta matches 1 run scoreboard players operation #cr_tt zx.meta += #cr_rem zx.meta

# ---- 槽 1 ----
data remove storage zx:work cr.s
execute if data entity @s Inventory[{Slot:1b}].components."minecraft:custom_data".skill run data modify storage zx:work cr.s set from entity @s Inventory[{Slot:1b}].components."minecraft:custom_data".skill
scoreboard players set #cr_e zx.meta 0
execute if data storage zx:work cr.s unless data storage zx:work cr{s:"sweetdream:crescent"} run scoreboard players set #cr_e zx.meta 1
$data modify storage manacore:in arg set value {uuid:"$(uuid)",skill:""}
execute if score #cr_e zx.meta matches 1 run data modify storage manacore:in arg.skill set from storage zx:work cr.s
execute if score #cr_e zx.meta matches 1 run function manacore:api/cooldown/get
execute if score #cr_e zx.meta matches 1 unless data storage manacore:out r{ready:0b} run scoreboard players set #cr_e zx.meta 0
$execute if score #cr_e zx.meta matches 1 run data modify storage zx:freeze p."$(uuid)".s1 set from storage zx:work cr.s
scoreboard players set #cr_rem zx.meta 0
execute if score #cr_e zx.meta matches 1 store result score #cr_rem zx.meta run data get storage manacore:out r.remaining
execute if score #cr_e zx.meta matches 1 run scoreboard players operation #cr_tt zx.meta += #cr_rem zx.meta

# ---- 槽 2 ----
data remove storage zx:work cr.s
execute if data entity @s Inventory[{Slot:2b}].components."minecraft:custom_data".skill run data modify storage zx:work cr.s set from entity @s Inventory[{Slot:2b}].components."minecraft:custom_data".skill
scoreboard players set #cr_e zx.meta 0
execute if data storage zx:work cr.s unless data storage zx:work cr{s:"sweetdream:crescent"} run scoreboard players set #cr_e zx.meta 1
$data modify storage manacore:in arg set value {uuid:"$(uuid)",skill:""}
execute if score #cr_e zx.meta matches 1 run data modify storage manacore:in arg.skill set from storage zx:work cr.s
execute if score #cr_e zx.meta matches 1 run function manacore:api/cooldown/get
execute if score #cr_e zx.meta matches 1 unless data storage manacore:out r{ready:0b} run scoreboard players set #cr_e zx.meta 0
$execute if score #cr_e zx.meta matches 1 run data modify storage zx:freeze p."$(uuid)".s2 set from storage zx:work cr.s
scoreboard players set #cr_rem zx.meta 0
execute if score #cr_e zx.meta matches 1 store result score #cr_rem zx.meta run data get storage manacore:out r.remaining
execute if score #cr_e zx.meta matches 1 run scoreboard players operation #cr_tt zx.meta += #cr_rem zx.meta

# ---- 槽 3 ----
data remove storage zx:work cr.s
execute if data entity @s Inventory[{Slot:3b}].components."minecraft:custom_data".skill run data modify storage zx:work cr.s set from entity @s Inventory[{Slot:3b}].components."minecraft:custom_data".skill
scoreboard players set #cr_e zx.meta 0
execute if data storage zx:work cr.s unless data storage zx:work cr{s:"sweetdream:crescent"} run scoreboard players set #cr_e zx.meta 1
$data modify storage manacore:in arg set value {uuid:"$(uuid)",skill:""}
execute if score #cr_e zx.meta matches 1 run data modify storage manacore:in arg.skill set from storage zx:work cr.s
execute if score #cr_e zx.meta matches 1 run function manacore:api/cooldown/get
execute if score #cr_e zx.meta matches 1 unless data storage manacore:out r{ready:0b} run scoreboard players set #cr_e zx.meta 0
$execute if score #cr_e zx.meta matches 1 run data modify storage zx:freeze p."$(uuid)".s3 set from storage zx:work cr.s
scoreboard players set #cr_rem zx.meta 0
execute if score #cr_e zx.meta matches 1 store result score #cr_rem zx.meta run data get storage manacore:out r.remaining
execute if score #cr_e zx.meta matches 1 run scoreboard players operation #cr_tt zx.meta += #cr_rem zx.meta

# ---- 槽 4 ----
data remove storage zx:work cr.s
execute if data entity @s Inventory[{Slot:4b}].components."minecraft:custom_data".skill run data modify storage zx:work cr.s set from entity @s Inventory[{Slot:4b}].components."minecraft:custom_data".skill
scoreboard players set #cr_e zx.meta 0
execute if data storage zx:work cr.s unless data storage zx:work cr{s:"sweetdream:crescent"} run scoreboard players set #cr_e zx.meta 1
$data modify storage manacore:in arg set value {uuid:"$(uuid)",skill:""}
execute if score #cr_e zx.meta matches 1 run data modify storage manacore:in arg.skill set from storage zx:work cr.s
execute if score #cr_e zx.meta matches 1 run function manacore:api/cooldown/get
execute if score #cr_e zx.meta matches 1 unless data storage manacore:out r{ready:0b} run scoreboard players set #cr_e zx.meta 0
$execute if score #cr_e zx.meta matches 1 run data modify storage zx:freeze p."$(uuid)".s4 set from storage zx:work cr.s
scoreboard players set #cr_rem zx.meta 0
execute if score #cr_e zx.meta matches 1 store result score #cr_rem zx.meta run data get storage manacore:out r.remaining
execute if score #cr_e zx.meta matches 1 run scoreboard players operation #cr_tt zx.meta += #cr_rem zx.meta

# ---- 槽 5 ----
data remove storage zx:work cr.s
execute if data entity @s Inventory[{Slot:5b}].components."minecraft:custom_data".skill run data modify storage zx:work cr.s set from entity @s Inventory[{Slot:5b}].components."minecraft:custom_data".skill
scoreboard players set #cr_e zx.meta 0
execute if data storage zx:work cr.s unless data storage zx:work cr{s:"sweetdream:crescent"} run scoreboard players set #cr_e zx.meta 1
$data modify storage manacore:in arg set value {uuid:"$(uuid)",skill:""}
execute if score #cr_e zx.meta matches 1 run data modify storage manacore:in arg.skill set from storage zx:work cr.s
execute if score #cr_e zx.meta matches 1 run function manacore:api/cooldown/get
execute if score #cr_e zx.meta matches 1 unless data storage manacore:out r{ready:0b} run scoreboard players set #cr_e zx.meta 0
$execute if score #cr_e zx.meta matches 1 run data modify storage zx:freeze p."$(uuid)".s5 set from storage zx:work cr.s
scoreboard players set #cr_rem zx.meta 0
execute if score #cr_e zx.meta matches 1 store result score #cr_rem zx.meta run data get storage manacore:out r.remaining
execute if score #cr_e zx.meta matches 1 run scoreboard players operation #cr_tt zx.meta += #cr_rem zx.meta

# ---- 槽 6 ----
data remove storage zx:work cr.s
execute if data entity @s Inventory[{Slot:6b}].components."minecraft:custom_data".skill run data modify storage zx:work cr.s set from entity @s Inventory[{Slot:6b}].components."minecraft:custom_data".skill
scoreboard players set #cr_e zx.meta 0
execute if data storage zx:work cr.s unless data storage zx:work cr{s:"sweetdream:crescent"} run scoreboard players set #cr_e zx.meta 1
$data modify storage manacore:in arg set value {uuid:"$(uuid)",skill:""}
execute if score #cr_e zx.meta matches 1 run data modify storage manacore:in arg.skill set from storage zx:work cr.s
execute if score #cr_e zx.meta matches 1 run function manacore:api/cooldown/get
execute if score #cr_e zx.meta matches 1 unless data storage manacore:out r{ready:0b} run scoreboard players set #cr_e zx.meta 0
$execute if score #cr_e zx.meta matches 1 run data modify storage zx:freeze p."$(uuid)".s6 set from storage zx:work cr.s
scoreboard players set #cr_rem zx.meta 0
execute if score #cr_e zx.meta matches 1 store result score #cr_rem zx.meta run data get storage manacore:out r.remaining
execute if score #cr_e zx.meta matches 1 run scoreboard players operation #cr_tt zx.meta += #cr_rem zx.meta

# ---- 槽 7 ----
data remove storage zx:work cr.s
execute if data entity @s Inventory[{Slot:7b}].components."minecraft:custom_data".skill run data modify storage zx:work cr.s set from entity @s Inventory[{Slot:7b}].components."minecraft:custom_data".skill
scoreboard players set #cr_e zx.meta 0
execute if data storage zx:work cr.s unless data storage zx:work cr{s:"sweetdream:crescent"} run scoreboard players set #cr_e zx.meta 1
$data modify storage manacore:in arg set value {uuid:"$(uuid)",skill:""}
execute if score #cr_e zx.meta matches 1 run data modify storage manacore:in arg.skill set from storage zx:work cr.s
execute if score #cr_e zx.meta matches 1 run function manacore:api/cooldown/get
execute if score #cr_e zx.meta matches 1 unless data storage manacore:out r{ready:0b} run scoreboard players set #cr_e zx.meta 0
$execute if score #cr_e zx.meta matches 1 run data modify storage zx:freeze p."$(uuid)".s7 set from storage zx:work cr.s
scoreboard players set #cr_rem zx.meta 0
execute if score #cr_e zx.meta matches 1 store result score #cr_rem zx.meta run data get storage manacore:out r.remaining
execute if score #cr_e zx.meta matches 1 run scoreboard players operation #cr_tt zx.meta += #cr_rem zx.meta

# ---- 槽 8 ----
data remove storage zx:work cr.s
execute if data entity @s Inventory[{Slot:8b}].components."minecraft:custom_data".skill run data modify storage zx:work cr.s set from entity @s Inventory[{Slot:8b}].components."minecraft:custom_data".skill
scoreboard players set #cr_e zx.meta 0
execute if data storage zx:work cr.s unless data storage zx:work cr{s:"sweetdream:crescent"} run scoreboard players set #cr_e zx.meta 1
$data modify storage manacore:in arg set value {uuid:"$(uuid)",skill:""}
execute if score #cr_e zx.meta matches 1 run data modify storage manacore:in arg.skill set from storage zx:work cr.s
execute if score #cr_e zx.meta matches 1 run function manacore:api/cooldown/get
execute if score #cr_e zx.meta matches 1 unless data storage manacore:out r{ready:0b} run scoreboard players set #cr_e zx.meta 0
$execute if score #cr_e zx.meta matches 1 run data modify storage zx:freeze p."$(uuid)".s8 set from storage zx:work cr.s
scoreboard players set #cr_rem zx.meta 0
execute if score #cr_e zx.meta matches 1 store result score #cr_rem zx.meta run data get storage manacore:out r.remaining
execute if score #cr_e zx.meta matches 1 run scoreboard players operation #cr_tt zx.meta += #cr_rem zx.meta

# ③ 加成% = Σ剩余tick / 20(向下取整), 上限 150
scoreboard players operation @s zx.cr_b = #cr_tt zx.meta
scoreboard players operation @s zx.cr_b /= #20 zx.meta
execute if score @s zx.cr_b matches 151.. run scoreboard players set @s zx.cr_b 150
