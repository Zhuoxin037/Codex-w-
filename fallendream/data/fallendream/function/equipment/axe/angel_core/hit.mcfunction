# ============================================================
# fallendream:equipment/axe/angel_core/hit —— 天使核心被动: 每次平A的钩子
# ------------------------------------------------------------
# 【谁调用它】进度 fallendream:equipment/axe/angel_core_hit(player_hurt_entity, 只算平A)
# 【执行者】动手的玩家
# 【首行 revoke 自己】见 lib/rearm —— 不撤的话只有第一次平A会触发。
# 【武器判定】被动是这把斧头的被动, 所以要"手上(主手或副手)是天使核心"才生效。
# 【★ "每次攻击" = 一次平A算一次(命中几只都一样) ★】玩家 2026-10-07 定稿的措辞口径:
#   文案写「每次攻击(后)」-> 按**攻击次数**算; 文案写「攻击到生物」-> 才按**命中数**算。
#   本件文案是"每次攻击后…使离自身 8 格内最近的 3 个生物附加「圣痕」", 所以走一次算一次
#   (实现 = 下面按游戏刻去重那两行)。
# ============================================================

advancement revoke @s only fallendream:equipment/axe/angel_core_hit
# ---- 满蓄力闸(2026-10-10, 全包统一口径) ----
#   平A 没**蓄满力**这一发就不触发本被动。判定与出参见 lib/atk_charge 头部
#   (每刻只算一次 + 玩家级 `@s zx.atk_ok`)。
#   ★ 必须排在 revoke 之后: lib/rearm 契约要求 revoke 是奖励函数第一非注释行。
function fallendream:lib/atk_charge
execute unless score @s zx.atk_ok matches 1 run return 0

scoreboard players set #ac_ok zx.meta 0
execute if items entity @s weapon.mainhand netherite_axe[custom_data~{zx:["angel_core"]}] run scoreboard players set #ac_ok zx.meta 1
execute if items entity @s weapon.offhand netherite_axe[custom_data~{zx:["angel_core"]}] run scoreboard players set #ac_ok zx.meta 1
execute unless score #ac_ok zx.meta matches 1 run return 0

# 【超限（2026-11-22）】这一次平A拿的是不是超限版
#   ★ 只有被动链里两处用到，但都要用 ★
#     · mark：圣痕时长 15 → 20 秒
#     · hit_go ⑦：3 格内 1 个圣痕者 +1 额外层
#   ★ 放在同刻去重**之前**：去重那条 return 掉的重复调用本来也不会进 hit_go，
#     但把判定写在前面，读代码时"武器 -> 档位 -> 去重"的顺序更清楚。
scoreboard players set #ac_ol zx.meta 0
execute if items entity @s weapon.mainhand netherite_axe[custom_data~{zx:["angel_core"],ol:"angel_core"}] run scoreboard players set #ac_ol zx.meta 1
execute if items entity @s weapon.offhand netherite_axe[custom_data~{zx:["angel_core"],ol:"angel_core"}] run scoreboard players set #ac_ol zx.meta 1

# 【★ 同一刻只算一次 ★】这个进度是 `player_hurt_entity` —— **每命中一个生物触发一次**。
#   平A带横扫打 3 只 => 这个函数同一刻跑 3 遍 => 魔力扣 3 次(240 点)、圣痕铺 3 轮。
#   按**游戏刻**去重: 这刻已经结算过就直接退出。
#   · 用 #now(框架时钟)而不是别的: 天然免疫暂停/TPS, 且横扫的多次伤害确实同刻。
#   · 没分数的玩家 `if score ... = #now` 直接判失败 => 第一次照样放行。
#   · 放在武器门控**之后**: 没拿天使核心就什么都不做, 也不必写这个时间戳。
#   · 戳在 hit_go **之前**写: 就算这次因为"魔力不到 80 / 目标都有圣痕"没生效,
#     同一次平A的后续重复调用也照样跳过(同一次攻击只结算一次)。
execute if score @s zx.ac_lt = #now manacore.meta run return 0
scoreboard players operation @s zx.ac_lt = #now manacore.meta

function fallendream:equipment/axe/angel_core/hit_go
