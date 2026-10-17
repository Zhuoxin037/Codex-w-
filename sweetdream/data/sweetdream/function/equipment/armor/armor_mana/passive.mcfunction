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
# ---- 批 15-2(2026-10-15): 归息(胸甲) +140 / 烛跬(靴) +90 ----
#   ★ 本批只登记**已实装**的那两件; 杂纹(护腿 +150) 等它的效果批次一起上 ——
#     先给个光秃秃的上限会让玩家以为"这件已经做完了"。
execute if items entity @s armor.chest *[minecraft:custom_data~{zx:["last_breath"]}] run scoreboard players add #want zx.meta 140
execute if items entity @s armor.feet *[minecraft:custom_data~{zx:["candle_step"]}] run scoreboard players add #want zx.meta 90
# ---- 批 15-3(2026-10-15): 沸痕(胸) +80 / 刺纹(腿) +60 / 滩纹(腿) +40 / 轻枕(靴) +40 / 渡梦(靴) +120 ----
execute if items entity @s armor.chest *[minecraft:custom_data~{zx:["boil_trace"]}] run scoreboard players add #want zx.meta 80
execute if items entity @s armor.legs *[minecraft:custom_data~{zx:["thorn_vein"]}] run scoreboard players add #want zx.meta 60
execute if items entity @s armor.legs *[minecraft:custom_data~{zx:["beach_vein"]}] run scoreboard players add #want zx.meta 40
execute if items entity @s armor.feet *[minecraft:custom_data~{zx:["light_pillow"]}] run scoreboard players add #want zx.meta 40
execute if items entity @s armor.feet *[minecraft:custom_data~{zx:["cross_dream"]}] run scoreboard players add #want zx.meta 120
# ---- 批 15-4(2026-10-16)· 五套双件套 10 件 ----
#   ★ 十件全部登记(它们的**单件被动与套装效果本轮都实装了**), 与 15-2 那条
#     "只登记已实装的"原则一致 —— 杂纹(+150)至今未实装, 所以仍然不登记。
#   燧行: 燧帽(头盔) +40 / 烟履(靴) +40
execute if items entity @s armor.head *[minecraft:custom_data~{zx:["flint_hat"]}] run scoreboard players add #want zx.meta 40
execute if items entity @s armor.feet *[minecraft:custom_data~{zx:["smoke_step"]}] run scoreboard players add #want zx.meta 40
#   潮线: 候潮(胸) +60 / 滩纹(腿) +40(15-3 已登记, 见上文)
execute if items entity @s armor.chest *[minecraft:custom_data~{zx:["tide_watch"]}] run scoreboard players add #want zx.meta 60
#   缝心: 针眠(头盔) +100 / 绯缝(胸) +120
execute if items entity @s armor.head *[minecraft:custom_data~{zx:["needle_sleep"]}] run scoreboard players add #want zx.meta 100
execute if items entity @s armor.chest *[minecraft:custom_data~{zx:["crimson_seam"]}] run scoreboard players add #want zx.meta 120
#   浅梦: 镜寐(腿) +60 / 轻枕(靴) +40(15-3 已登记, 见上文)
execute if items entity @s armor.legs *[minecraft:custom_data~{zx:["mirror_sleep"]}] run scoreboard players add #want zx.meta 60
#   残烛: 焦衣(胸) +130 / 烛跬(靴) +90(15-2 已登记, 见上文)
execute if items entity @s armor.chest *[minecraft:custom_data~{zx:["char_coat"]}] run scoreboard players add #want zx.meta 130
# ---- 批 15-5(2026-10-16)· 术阵/领域/召唤物 ----
#   凝壳: 凝壳(胸) +160
execute if items entity @s armor.chest *[minecraft:custom_data~{zx:["condensed_shell"]}] run scoreboard players add #want zx.meta 160
# ---- 批 15-7(2026-10-17)· 连接/转化/资源 ----
#   杂纹: 杂纹(腿) +150 —— 它的被动本轮已实装(consume/hook_calc/hit), 所以现在登记。
#   ★ 15-2 那条"只登记已实装的"原则到此为止: 剩余未实装件的上限加成仍不登记。★
execute if items entity @s armor.legs *[minecraft:custom_data~{zx:["mottle_vein"]}] run scoreboard players add #want zx.meta 150
# ---- 批 14 补技能(2026-10-17) ----
#   空枕: 空枕(头盔) +50 —— 被动本轮已实装(on_deal + passive)。
execute if items entity @s armor.head *[minecraft:custom_data~{zx:["empty_pillow"]}] run scoreboard players add #want zx.meta 50

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

# ---- 批 14 补技能(2026-10-17): 踏灰 / 雨迹 / 返照 / 回旋 的魔力上限 ----
#   ★ 必须放在"④ 差值计算"**之前** —— 那一段之后再改 #want 就不会被 apply 了。
#   踏灰(靴) +100 / 雨迹(靴) +50 / 返照(头盔) +160 / 回旋(护腿) +140
execute if items entity @s armor.feet *[minecraft:custom_data~{zx:["tread_ash"]}] run scoreboard players add #want zx.meta 100
execute if items entity @s armor.feet *[minecraft:custom_data~{zx:["rain_trace"]}] run scoreboard players add #want zx.meta 50
execute if items entity @s armor.head *[minecraft:custom_data~{zx:["backlight"]}] run scoreboard players add #want zx.meta 160
execute if items entity @s armor.legs *[minecraft:custom_data~{zx:["gyre"]}] run scoreboard players add #want zx.meta 140

# ---- ④ 差值 = 该有的 - 账本已加的; 不为 0 就补/退 ----
scoreboard players operation #diff zx.meta = #want zx.meta
scoreboard players operation #diff zx.meta -= @s zx.am_mana
execute unless score #diff zx.meta matches 0 run function sweetdream:equipment/armor/armor_mana/apply_mana
