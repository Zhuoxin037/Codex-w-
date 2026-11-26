# ============================================================
# fallendream:equipment/sword/oath_victory/hit —— 胜利誓约 · 被动（20% 给 5 点临时生命）
# ------------------------------------------------------------
# 【谁调用它】进度 fallendream:equipment/sword/oath_victory_hit（player_hurt_entity，只算平A）
# 【执行者】动手的玩家
# 【文案】"每次普攻命中生物后，有 20% 的概率使自身获得 5 点临时生命值。"
# 【★ 四要素 ★】① 触发=普攻命中（一次平A一次）② 概率 20% = %5 ③ 次数 1 ④ 时长：临时
#   生命按 lib/thp 的 60 秒上限走（文案没写时长，包内统一口径见 lib/thp/set）。
# 【★ 同刻去重 ★】player_hurt_entity **每命中一只就抛一次**（横扫打 3 只 = 同刻 3 遍）
#   ⇒ 用 zx.ov_lt 记"本刻已结算"。没分数的玩家 `if score = #now` 判失败 ⇒ 第一次放行。
# ============================================================

advancement revoke @s only fallendream:equipment/sword/oath_victory_hit
# 满蓄力闸（全包统一口径，见 lib/atk_charge 头部）
function fallendream:lib/atk_charge
execute unless score @s zx.atk_ok matches 1 run return 0

# 武器门控：主手或副手是胜利誓约
scoreboard players set #ov_ok zx.meta 0
execute if items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["oath_victory"]}] run scoreboard players set #ov_ok zx.meta 1
execute if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["oath_victory"]}] run scoreboard players set #ov_ok zx.meta 1
execute unless score #ov_ok zx.meta matches 1 run return 0

# 每次攻击去重
execute if score @s zx.ov_lt = #now manacore.meta run return 0
scoreboard players operation @s zx.ov_lt = #now manacore.meta

# 20%（掷骰一定要掷，保持序列连续）
function fallendream:lib/rnd
scoreboard players operation #ov_r zx.meta = #rnd zx.meta
scoreboard players set #ov_5 zx.meta 5
scoreboard players operation #ov_r zx.meta %= #ov_5 zx.meta
execute unless score #ov_r zx.meta matches 0 run return 0

# +5 点临时生命（上限 = 最大生命 ×2，由 lib/thp/add 夹）
scoreboard players set #thp_v zx.meta 5
function fallendream:lib/thp/add

# 表现
particle minecraft:end_rod ~ ~1 ~ 0.3 0.4 0.3 0.02 8 normal
