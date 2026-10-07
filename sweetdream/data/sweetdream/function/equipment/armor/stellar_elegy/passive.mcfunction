# ============================================================
# sweetdream:equipment/armor/stellar_elegy/passive —— 魔力上限 +280(以玩家身份)
# ------------------------------------------------------------
# 【文案】被动: 自身魔力值上限 +280。
# 【套路和其它护甲一样】认装备 -> 算目标值 -> 和账本求差 -> 只加差值。
#   账本 = zx.se_mana, 所以穿上 +280、脱下 -280, 不会冲掉别的来源的上限加成。
# 【判定用 ~ 部分匹配 + 独有标记】custom_data~{zx:["stellar_elegy"]}
#   用 = 是精确比对(多一段少一段就静默失效, 踩过两次), 而且标记必须是这件装备独有的。
# ============================================================

function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

function sweetdream:equipment/armor/stellar_elegy/is_ol

scoreboard players set #se_on zx.meta 0
execute if items entity @s armor.legs netherite_leggings[custom_data~{zx:["stellar_elegy"]}] run scoreboard players set #se_on zx.meta 1

# ★ 超限版: 上限 280 -> 350(文案给的是这一级的**完整值**, 不是"再加 350")
scoreboard players set #want zx.meta 0
execute if score #se_on zx.meta matches 1 run scoreboard players set #want zx.meta 280
execute if score #se_on zx.meta matches 1 if score #se_ol zx.meta matches 1 run scoreboard players set #want zx.meta 350
scoreboard players operation #diff zx.meta = #want zx.meta
scoreboard players operation #diff zx.meta -= @s zx.se_mana
execute unless score #diff zx.meta matches 0 run function sweetdream:equipment/armor/stellar_elegy/apply_mana
