# ============================================================
# sweetdream:equipment/armor/armor_mana/passive —— 重算"该有多少魔力上限加成"
# ------------------------------------------------------------
# 【执行者】每个玩家(second 用 `as @a` 送进来)
# 【入参/出参】#want = 本秒该有的总加成; 与账本 @s zx.am_mana 比差值 -> apply_mana
# 【口径(逐字对 lore)】
#   · 聚魔头盔  +10
#   · 聚魔胸甲  +20; 二件套A「聚魔」(聚魔头盔+聚魔胸甲)再 +20
#   · 魔化腰带  +60; 二件套B(魔化腰带+血肉磨坊)再 +80  ← 与「聚魔」是两套独立
#   · 焱(胸甲) +100
#   · 灵视(头盔) +70
#   · 息影(护腿) +90
#   · 血肉磨坊(靴): 本身不给上限; 二件套B(腰带+靴) +80
# ★ 两套各自独立, 不存在"四件套"。2026-10-08 事故: 曾误合成一个四件套(要四件才给
#   +80), 那是凭空加的设定, 已拆回两套。
# 【槽位】头盔=armor.head / 胸甲=armor.chest / 护腿=armor.legs / 靴=armor.feet
# ============================================================

function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# ---- ① 各槽位单件加成 ----
scoreboard players set #want zx.meta 0
execute if items entity @s armor.head *[minecraft:custom_data~{zx:["mana_helm"]}] run scoreboard players add #want zx.meta 10
execute if items entity @s armor.head *[minecraft:custom_data~{zx:["spirit_sight"]}] run scoreboard players add #want zx.meta 70
execute if items entity @s armor.chest *[minecraft:custom_data~{zx:["mana_plate"]}] run scoreboard players add #want zx.meta 20
execute if items entity @s armor.chest *[minecraft:custom_data~{zx:["blaze_armor"]}] run scoreboard players add #want zx.meta 100
execute if items entity @s armor.legs *[minecraft:custom_data~{zx:["hex_belt"]}] run scoreboard players add #want zx.meta 60
execute if items entity @s armor.legs *[minecraft:custom_data~{zx:["fade"]}] run scoreboard players add #want zx.meta 90

# ---- ② 二件套: 聚魔头盔 + 聚魔胸甲 -> 再 +20(#mp12 = 两件都在) ----
scoreboard players set #mp1 zx.meta 0
execute if items entity @s armor.head *[minecraft:custom_data~{zx:["mana_helm"]}] run scoreboard players set #mp1 zx.meta 1
scoreboard players set #mp2 zx.meta 0
execute if items entity @s armor.chest *[minecraft:custom_data~{zx:["mana_plate"]}] run scoreboard players set #mp2 zx.meta 1
scoreboard players operation #mp12 zx.meta = #mp1 zx.meta
scoreboard players operation #mp12 zx.meta *= #mp2 zx.meta
execute if score #mp12 zx.meta matches 1 run scoreboard players add #want zx.meta 20

# ---- ③ 二件套B「魔化腰带 + 血肉磨坊」-> +80 ----
#   ★★ 这是【独立的一套】, 与上面的「聚魔」(头盔+胸甲)无关 —— 2026-10-08 曾把它俩
#      揉成一个"聚魔四件套"(要四件才 +80), 那是错的: 腰带+靴 两件就该给。
scoreboard players set #mp3 zx.meta 0
execute if items entity @s armor.legs *[minecraft:custom_data~{zx:["hex_belt"]}] run scoreboard players set #mp3 zx.meta 1
scoreboard players set #mp4 zx.meta 0
execute if items entity @s armor.feet *[minecraft:custom_data~{zx:["flesh_mill"]}] run scoreboard players set #mp4 zx.meta 1
scoreboard players operation #mp34 zx.meta = #mp3 zx.meta
scoreboard players operation #mp34 zx.meta *= #mp4 zx.meta
execute if score #mp34 zx.meta matches 1 run scoreboard players add #want zx.meta 80

# ---- ④ 差值 = 该有的 - 账本已加的; 不为 0 就补/退 ----
scoreboard players operation #diff zx.meta = #want zx.meta
scoreboard players operation #diff zx.meta -= @s zx.am_mana
execute unless score #diff zx.meta matches 0 run function sweetdream:equipment/armor/armor_mana/apply_mana
