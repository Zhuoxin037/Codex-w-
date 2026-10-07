# ============================================================
# sweetdream:equipment/armor/dusk_dawn/low_mana —— 魔力低于阈值时每秒回蓝
# ------------------------------------------------------------
# 【原版文案】若自身魔力值低于魔力值上限 50% 则每秒获得 20 魔力值。
# 【超限版文案】若自身魔力值低于魔力值上限 80% 则每秒获得 3% 魔力值。
# 【怎么比"低于 N%"】把两边各乘一个整数再比(避免做除法丢精度):
#   50%: 当前 ×2 < 上限 ×1    <=>  当前 < 上限的一半
#   80%: 当前 ×5 < 上限 ×4    <=>  当前 < 上限的 4/5
# 【★ 先判穿着 ★】这一份是 `execute as @a` 广播调用的(见 second),
#   函数体内不自己判装备的话 **没穿的人也每秒回蓝** —— 2026-10-04 实测事故:
#   脱掉「黄昏黎明之交界」, 只要魔力低于一半照样每秒涨 20。
# 【★ 这里必须自己调 lib/uuid ★】second 里它排在 passive 之后, 而 passive 是
#   `execute as @a` 逐个跑的 —— zx:data self.uuid 里留的是**最后一个玩家**的 UUID。
#   多人时会"拿别人的魔力条判阈值 / 给别人回蓝"。单人碰巧正确, 所以一直没暴露。
# ============================================================

execute unless items entity @s armor.feet netherite_boots[custom_data~{zx:["dusk_dawn"]}] run return 0
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0
function sweetdream:equipment/armor/dusk_dawn/is_ol

data modify storage manacore:in arg set value {uuid:""}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/mana/get
execute store result score #cur zx.meta run data get storage manacore:out r.value
execute store result score #max zx.meta run data get storage manacore:out r.max

# 原版: 低于 50% -> 每秒 +20
scoreboard players operation #dbl zx.meta = #cur zx.meta
scoreboard players operation #dbl zx.meta *= #2 zx.meta
execute unless score #dd_ol zx.meta matches 1 if score #dbl zx.meta < #max zx.meta run function sweetdream:equipment/armor/dusk_dawn/low_mana_add

# 超限版: 低于 80% -> 每秒 +3% 最大魔力
scoreboard players operation #dd_a zx.meta = #cur zx.meta
scoreboard players operation #dd_a zx.meta *= #5 zx.meta
scoreboard players operation #dd_b zx.meta = #max zx.meta
scoreboard players operation #dd_b zx.meta *= #4 zx.meta
execute if score #dd_ol zx.meta matches 1 if score #dd_a zx.meta < #dd_b zx.meta run function sweetdream:equipment/armor/dusk_dawn/low_mana_pct
