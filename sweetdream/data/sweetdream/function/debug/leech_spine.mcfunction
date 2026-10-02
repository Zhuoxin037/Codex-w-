# ============================================================
# sweetdream:debug/leech_spine —— 查脑髓蛭 / 脊骨共生的实时状态
# ------------------------------------------------------------
# 【用法】/function sweetdream:debug/leech_spine
# 【看什么】
#   ① 两件在不在身上、套装成不成立
#   ② 三个魔力上限账本: 脑髓蛭 / 脊骨共生 / 下限保护垫了多少
#   ③ 每秒 +3 回魔的修正挂上没有
#   ④ 攻击力 / 护甲 / 生命上限三个账本, 以及真实属性各是多少
# 【怎么判断对不对】
#   · 只穿这一套时, 魔力上限会被托到 20(基础 100 - 120 - 180 = -200),
#     此时"下限垫高"应该是 220 —— 不是 220 就说明托底没生效。
#   · 魔力满时攻击/护甲/血量账本应该 = floor(上限 × 0.03), 不满时应为 0。
#   · 脱下装备后所有账本应该回到 0, 真实属性也跟着回落。
# ============================================================

scoreboard players add @s zx.bl_mana 0
scoreboard players add @s zx.bl_regen 0
scoreboard players add @s zx.bl_atk 0
scoreboard players add @s zx.ss_mana 0
scoreboard players add @s zx.ss_armor 0
scoreboard players add @s zx.ss_hp 0
scoreboard players add @s zx.floor_mana 0

tellraw @s [{"text":"===== 脑髓蛭 / 脊骨共生 =====","color":"light_purple","bold":true}]
execute if items entity @s armor.head diamond_helmet[custom_data~{zx:["brain_leech"]}] run tellraw @s [{"text":"脑髓蛭(头盔): ","color":"gray"},{"text":"已装备","color":"green"}]
execute unless items entity @s armor.head diamond_helmet[custom_data~{zx:["brain_leech"]}] run tellraw @s [{"text":"脑髓蛭(头盔): ","color":"gray"},{"text":"未装备","color":"red"}]
execute if items entity @s armor.chest diamond_chestplate[custom_data~{zx:["spine_symbiote"]}] run tellraw @s [{"text":"脊骨共生(胸甲): ","color":"gray"},{"text":"已装备","color":"green"}]
execute unless items entity @s armor.chest diamond_chestplate[custom_data~{zx:["spine_symbiote"]}] run tellraw @s [{"text":"脊骨共生(胸甲): ","color":"gray"},{"text":"未装备","color":"red"}]

tellraw @s [{"text":"魔力上限账本  脑髓蛭 ","color":"gray"},{"score":{"name":"@s","objective":"zx.bl_mana"},"color":"aqua"},{"text":"  脊骨共生 ","color":"gray"},{"score":{"name":"@s","objective":"zx.ss_mana"},"color":"aqua"},{"text":"  下限垫高 ","color":"gray"},{"score":{"name":"@s","objective":"zx.floor_mana"},"color":"yellow"}]
execute if score @s zx.bl_regen matches 1.. run tellraw @s [{"text":"每秒 +3 回魔: ","color":"gray"},{"text":"已挂上","color":"green"}]
execute unless score @s zx.bl_regen matches 1.. run tellraw @s [{"text":"每秒 +3 回魔: ","color":"gray"},{"text":"未挂","color":"red"}]
tellraw @s [{"text":"加成账本  攻击 ","color":"gray"},{"score":{"name":"@s","objective":"zx.bl_atk"},"color":"gold"},{"text":"  护甲 ","color":"gray"},{"score":{"name":"@s","objective":"zx.ss_armor"},"color":"gold"},{"text":"  生命 ","color":"gray"},{"score":{"name":"@s","objective":"zx.ss_hp"},"color":"gold"}]

function sweetdream:lib/in_bak
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run function sweetdream:lib/in_restore
execute unless data storage zx:data self{ok:1b} run return 0

data modify storage manacore:in arg set value {uuid:""}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/mana/get
tellraw @s [{"text":"魔力 ","color":"gray"},{"nbt":"r.value","storage":"manacore:out","color":"aqua"},{"text":" / ","color":"gray"},{"nbt":"r.max","storage":"manacore:out","color":"light_purple"}]

execute store result score #dbg_atk zx.meta run attribute @s minecraft:attack_damage get 100
execute store result score #dbg_arm zx.meta run attribute @s minecraft:armor get 100
execute store result score #dbg_hp zx.meta run attribute @s minecraft:max_health get 100
tellraw @s [{"text":"真实属性  攻击 ","color":"gray"},{"score":{"name":"#dbg_atk","objective":"zx.meta"},"color":"white"},{"text":" (×0.01)   护甲 ","color":"dark_gray"},{"score":{"name":"#dbg_arm","objective":"zx.meta"},"color":"white"},{"text":"   生命 ","color":"gray"},{"score":{"name":"#dbg_hp","objective":"zx.meta"},"color":"white"}]

function sweetdream:lib/in_restore
