# ============================================================
# sweetdream:equipment/armor/dusk_dawn/passive —— 上限 +180 与套装(以玩家身份)
# ------------------------------------------------------------
# 【文案】被动: 自身魔力值上限 +180。套装(和「群星坠落之挽歌」一起):
#         自身魔力值上限 +200, 且自身每 3 秒恢复 1% 魔力值。
# 【套装为什么写在这一份里】套装要同时看两件, 放哪边都得知道另一件;
#   按约定统一放在靴子这份里(和体外供能装置那套一样)。
# 【判定用 ~ 部分匹配 + 独有标记】custom_data~{zx:["..."]} —— 用 = 会有
#   "多一段少一段就静默失效"的坑(踩过两次)。
# ============================================================

function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# ① 靴子本身: 穿着 +180
scoreboard players set #dd_on zx.meta 0
execute if items entity @s armor.feet netherite_boots[custom_data~{zx:["dusk_dawn"]}] run scoreboard players set #dd_on zx.meta 1
scoreboard players set #want zx.meta 0
execute if score #dd_on zx.meta matches 1 run scoreboard players set #want zx.meta 180
scoreboard players operation #diff zx.meta = #want zx.meta
scoreboard players operation #diff zx.meta -= @s zx.dd_mana
scoreboard players set #src zx.meta 1
execute unless score #diff zx.meta matches 0 run function sweetdream:equipment/armor/dusk_dawn/apply_mana

# ② 套装: 两件都穿 -> +200
scoreboard players set #se_on zx.meta 0
execute if items entity @s armor.legs netherite_leggings[custom_data~{zx:["stellar_elegy"]}] run scoreboard players set #se_on zx.meta 1
scoreboard players operation #set_on zx.meta = #se_on zx.meta
scoreboard players operation #set_on zx.meta *= #dd_on zx.meta
scoreboard players set #want zx.meta 0
execute if score #set_on zx.meta matches 1 run scoreboard players set #want zx.meta 200
scoreboard players operation #diff zx.meta = #want zx.meta
scoreboard players operation #diff zx.meta -= @s zx.dd_set
scoreboard players set #src zx.meta 2
execute unless score #diff zx.meta matches 0 run function sweetdream:equipment/armor/dusk_dawn/apply_mana

# ③ 给"穿着套装"的玩家挂/摘标签 —— 每 3 秒的 1% 回蓝只对带标签的人跑
execute if score #set_on zx.meta matches 1 run tag @s add zx.dd_set_on
execute if score #set_on zx.meta matches 0 run tag @s remove zx.dd_set_on
