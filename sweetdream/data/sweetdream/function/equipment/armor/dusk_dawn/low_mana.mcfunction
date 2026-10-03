# ============================================================
# sweetdream:equipment/armor/dusk_dawn/low_mana —— 魔力低于上限 50% 时每秒回 20
# ------------------------------------------------------------
# 【文案】若自身魔力值低于魔力值上限 50% 则每秒获得 20 魔力值。
# 【怎么比"低于 50%"】把当前魔力 ×2 和上限比(避免做除法丢精度):
#   当前 ×2 < 上限  <=>  当前 < 上限的一半
# 【★ 先判穿着 ★】这一份是 `execute as @a` 广播调用的(见 second 第 14 行),
#   函数体内不自己判装备的话 **没穿的人也每秒回 20** —— 2026-10-04 实测事故:
#   脱掉「黄昏黎明之交界」, 只要魔力低于一半照样每秒涨 20(玩家原话
#   "不论有没有穿上都会触发被动效果")。
#   本包其它装备的被动都在自己的 passive 里判了穿着(check.py 规则 29 会盯这件事),
#   以后加新装备照抄这一行。
# ============================================================

execute unless items entity @s armor.feet netherite_boots[custom_data~{zx:["dusk_dawn"]}] run return 0

data modify storage manacore:in arg set value {uuid:""}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/mana/get
execute store result score #cur zx.meta run data get storage manacore:out r.value
execute store result score #max zx.meta run data get storage manacore:out r.max
scoreboard players operation #dbl zx.meta = #cur zx.meta
scoreboard players operation #dbl zx.meta *= #2 zx.meta
execute if score #dbl zx.meta < #max zx.meta run function sweetdream:equipment/armor/dusk_dawn/low_mana_add
