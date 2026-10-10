# ============================================================
# sweetdream:equipment/armor/furnace_core/hit —— 打到燃烧中的生物: 攒一层燃灰
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:equipment/armor/furnace_core_hit
#   (player_hurt_entity + 伤害类型 is_player_attack + 受害者 is_on_fire)
# 【文案】自身每攻击一次处于燃烧状态的生物则积攒一层「燃灰」（最大为 10 层）。
# 【为什么限定 is_player_attack】不加这条的话, 技能伤害 / 法球 / 荆棘反弹
#   都会来攒层 —— 文案说的是"攻击", 只认平 A(规则 30)。
# 【★ 第一行必须是 revoke ★】一次性进度, 不撤就只有第一次会触发;
#   而且它必须排在 return 之前(规则 27)。
# 【★ 自己判穿着 ★】本函数由进度以玩家身份调用, 但"打到燃烧的怪"和"穿没穿炉心"
#   是两件事 —— 不判的话没穿也会攒层(静默 bug)。
# 【上限 10/12】到顶就夹住, 不再往上加(夹而不是"不加" —— 万一被别处推过头,
#   夹一下能自己回到正常区间)。
# ============================================================

advancement revoke @s only sweetdream:equipment/armor/furnace_core_hit
# ---- 满蓄力闸(2026-10-10, 全包统一口径) ----
#   平A 没**蓄满力**这一发就不触发本被动。判定与出参见 lib/atk_charge 头部
#   (每刻只算一次 + 玩家级 `@s zx.atk_ok`)。
#   ★ 必须排在 revoke 之后: lib/rearm 契约要求 revoke 是奖励函数第一非注释行。
function sweetdream:lib/atk_charge
execute unless score @s zx.atk_ok matches 1 run return 0

execute unless items entity @s armor.chest *[minecraft:custom_data~{zx:["furnace_core"]}] run return 0

scoreboard players add @s zx.fc_ash 0
scoreboard players add @s zx.fc_ash 1
# 上限: 基础 10 / 超限 12(超限·炉心: "最大为12层")
scoreboard players set #fc_cap zx.meta 10
execute if items entity @s armor.chest *[minecraft:custom_data~{zx:["furnace_core"],ol:"furnace_core"}] run scoreboard players set #fc_cap zx.meta 12
execute if score @s zx.fc_ash > #fc_cap zx.meta run scoreboard players operation @s zx.fc_ash = #fc_cap zx.meta
# 超限: 攒到 12 层 -> 12 秒内不再减层(倒计时 fc_hold, 见 passive ③; 结束直接降到 8 层)
execute if score #fc_cap zx.meta matches 12 if score @s zx.fc_ash matches 12 run scoreboard players set @s zx.fc_hold 12

# 表现: 一点火星(轻量 —— 这条每秒可能触发好几次)
execute at @s run particle minecraft:flame ~ ~1 ~ 0.35 0.5 0.35 0.01 6 normal
