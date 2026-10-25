# ============================================================
# sweetdream:equipment/axe/meteor/hit —— 陨星被动: 每次平A的钩子
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:equipment/axe/meteor_hit(player_hurt_entity, 只算平A)
# 【执行者】动手的玩家
# 【首行 revoke 自己】见 lib/rearm。
# 【★ "每次攻击" = 一次平A算一次(命中几只都一样) ★】玩家 2026-10-07 定稿的措辞口径:
#   文案写「每次攻击(后)」-> 按**攻击次数**算; 文案写「攻击到生物」-> 才按**命中数**算。
#   本件文案是"每次攻击都有 10% 的概率…降下一个陨石", 所以走一次算一次
#   (实现 = 下面按游戏刻去重那两行)。不去重的话横扫打 3 只 = 掷 3 次骰子,
#   10% 会变成 1-0.9³ ≈ 27%。
# ============================================================

advancement revoke @s only sweetdream:equipment/axe/meteor_hit
# ---- 满蓄力闸(2026-10-10, 全包统一口径) ----
#   平A 没**蓄满力**这一发就不触发本被动。判定与出参见 lib/atk_charge 头部
#   (每刻只算一次 + 玩家级 `@s zx.atk_ok`)。
#   ★ 必须排在 revoke 之后: lib/rearm 契约要求 revoke 是奖励函数第一非注释行。
function sweetdream:lib/atk_charge
execute unless score @s zx.atk_ok matches 1 run return 0

scoreboard players set #mt_ok zx.meta 0
# 超限·陨星(批 K6): 形态开着且 mt_keep=1 -> 换手也照样掷陨石(文案"被动仍旧生效")
#   ★ 必须**同时**判 mt_on ≥1 —— 只判 mt_keep 的话, 形态结束后(万一 end 没跑到)
#     拿着任何武器都会掷陨石。
execute if score @s zx.mt_keep matches 1 if score @s zx.mt_on matches 1.. run scoreboard players set #mt_ok zx.meta 1
execute if items entity @s weapon.mainhand diamond_axe[custom_data~{zx:["meteor"]}] run scoreboard players set #mt_ok zx.meta 1
execute if items entity @s weapon.offhand diamond_axe[custom_data~{zx:["meteor"]}] run scoreboard players set #mt_ok zx.meta 1
execute unless score #mt_ok zx.meta matches 1 run return 0

# 【★ 同一刻只算一次 ★】`player_hurt_entity` 每命中一个生物触发一次 —— 不同步去重的话
#   横扫命中数 = 掷骰子次数。按游戏刻去重(照 brain_leech/attack 的既定做法)。
#   · 放在武器门控之后; 戳在 hit_go 之前写(这次没掷中也要挡住同刻的重复调用)。
execute if score @s zx.mt_lt = #now manacore.meta run return 0
scoreboard players operation @s zx.mt_lt = #now manacore.meta

function sweetdream:equipment/axe/meteor/hit_go
