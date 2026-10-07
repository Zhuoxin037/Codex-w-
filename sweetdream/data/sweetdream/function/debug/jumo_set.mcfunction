# ============================================================
# sweetdream:debug/jumo_set —— 盔甲套装体检(只读, 不改任何东西)
# ------------------------------------------------------------
# 【怎么用】/function sweetdream:debug/jumo_set   (站在原地按就行)
# 【★ 2026-10-08 口径修正】这里有【两套各自独立】的二件套, 不存在"四件套":
#     套装A「聚魔」= 聚魔头盔(头) + 聚魔胸甲(胸)   -> 上限 +20
#     套装B         = 魔化腰带(腿) + 血肉磨坊(靴)   -> 上限 +80, 每秒额外 +1
#   之前误做成一个"聚魔四件套"(要四件齐才给 +80), 那是凭空加的设定。
# 【这个文件做什么】把四格逐个点名, 两套分别计数, 再把账本摊开:
#   ① 四格装备 认出来没有      ② 两套各自的件数(都要 2)
#   ③ 上限账本 zx.am_mana      ④ 上一秒实收 / 受伤窗口
#   ⑤ 当前 / 最大 魔力
#   —— ① 全绿而 ② 不是 2, 那是判定写错了; ① 有红的, 那就是没穿齐。
# ============================================================

tellraw @s [{"text":"—— 盔甲套装体检 ——","color":"gold","bold":true}]

# ---- ① 四格点名 ----
execute if items entity @s armor.head *[minecraft:custom_data~{zx:["mana_helm"]}] run tellraw @s [{"text":"① 头盔 · 聚魔头盔  ","color":"gray"},{"text":"✓","color":"green"}]
execute unless items entity @s armor.head *[minecraft:custom_data~{zx:["mana_helm"]}] run tellraw @s [{"text":"① 头盔 · 聚魔头盔  ","color":"gray"},{"text":"✗","color":"red"}]
execute if items entity @s armor.chest *[minecraft:custom_data~{zx:["mana_plate"]}] run tellraw @s [{"text":"   胸甲 · 聚魔胸甲  ","color":"gray"},{"text":"✓","color":"green"}]
execute unless items entity @s armor.chest *[minecraft:custom_data~{zx:["mana_plate"]}] run tellraw @s [{"text":"   胸甲 · 聚魔胸甲  ","color":"gray"},{"text":"✗","color":"red"}]
execute if items entity @s armor.legs *[minecraft:custom_data~{zx:["hex_belt"]}] run tellraw @s [{"text":"   护腿 · 魔化腰带  ","color":"gray"},{"text":"✓","color":"green"}]
execute unless items entity @s armor.legs *[minecraft:custom_data~{zx:["hex_belt"]}] run tellraw @s [{"text":"   护腿 · 魔化腰带  ","color":"gray"},{"text":"✗","color":"red"}]
execute if items entity @s armor.feet *[minecraft:custom_data~{zx:["flesh_mill"]}] run tellraw @s [{"text":"   靴子 · 血肉磨坊  ","color":"gray"},{"text":"✓","color":"green"}]
execute unless items entity @s armor.feet *[minecraft:custom_data~{zx:["flesh_mill"]}] run tellraw @s [{"text":"   靴子 · 血肉磨坊  ","color":"gray"},{"text":"✗","color":"red"}]

# ---- ② 两套分别计数(照抄 armor_mana/passive 与 flesh_mill/passive 那两路) ----
scoreboard players set #mp12 zx.meta 0
execute if items entity @s armor.head *[minecraft:custom_data~{zx:["mana_helm"]}] run scoreboard players add #mp12 zx.meta 1
execute if items entity @s armor.chest *[minecraft:custom_data~{zx:["mana_plate"]}] run scoreboard players add #mp12 zx.meta 1
tellraw @s [{"text":"② A聚魔(头+胸, 要 2): ","color":"gray"},{"score":{"name":"#mp12","objective":"zx.meta"},"color":"aqua"},{"text":"   → 上限 +20","color":"dark_gray"}]

scoreboard players set #mp34 zx.meta 0
execute if items entity @s armor.legs *[minecraft:custom_data~{zx:["hex_belt"]}] run scoreboard players add #mp34 zx.meta 1
execute if items entity @s armor.feet *[minecraft:custom_data~{zx:["flesh_mill"]}] run scoreboard players add #mp34 zx.meta 1
tellraw @s [{"text":"   B腰带+靴(要 2): ","color":"gray"},{"score":{"name":"#mp34","objective":"zx.meta"},"color":"aqua"},{"text":"   → 上限 +80, 每秒 +1","color":"dark_gray"}]

tellraw @s [{"text":"③ 上限账本 zx.am_mana: ","color":"gray"},{"score":{"name":"@s","objective":"zx.am_mana"},"color":"light_purple"}]
tellraw @s [{"text":"④ 上一秒实收 zx.regen_last: ","color":"gray"},{"score":{"name":"@s","objective":"zx.regen_last"},"color":"yellow"}]
tellraw @s [{"text":"   受伤窗口 zx.fm_t: ","color":"gray"},{"score":{"name":"@s","objective":"zx.fm_t"},"color":"yellow"}]

# ---- ⑤ 当前 / 最大魔力(走前置包接口; 公共输入口用 in_bak 保护) ----
function sweetdream:lib/in_bak
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run function sweetdream:lib/in_restore
execute unless data storage zx:data self{ok:1b} run return 0
data modify storage manacore:in arg set value {uuid:""}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/mana/get
tellraw @s [{"text":"⑤ 当前魔力: ","color":"gray"},{"nbt":"r.value","storage":"manacore:out","color":"aqua"}]
data modify storage manacore:in arg set value {uuid:"",key:"max_mana"}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/stats/get
tellraw @s [{"text":"   最大魔力: ","color":"gray"},{"nbt":"r.value","storage":"manacore:out","color":"light_purple"}]
function sweetdream:lib/in_restore
