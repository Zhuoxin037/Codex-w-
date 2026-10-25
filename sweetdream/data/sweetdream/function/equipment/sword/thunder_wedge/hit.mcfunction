# ============================================================
# sweetdream:equipment/sword/thunder_wedge/hit —— 雷楔 · 平A命中结算(被动「雷楔」)
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:equipment/sword/thunder_wedge_hit
#   (player_hurt_entity + damage.type.tags = minecraft:is_player_attack)
# 【执行者】玩家。它**不告诉我们打的是谁**, 所以要自己找(见 ⑥)。
# 【技能原文】"使用者攻击了“雷楔”8 格内的生物后，“雷楔”对命中位置释放一次闪电，
#   对其 1 格内的生物造成一次相当于使用者基础攻击力 ×2 的伤害，每秒最多触发一次。"
# 【★ 顺序不可乱 ★】
#   ⓪ revoke(奖励函数第一行; lib/rearm 契约盯着它)
#   ① 满蓄力闸(全包统一口径: 平A没蓄满这一发不触发被动)
#   ② 手持判定(带着别的武器平A不该触发 —— 雷楔的被动属于"使用者"手里的雷楔)
#   ③ 找"刚被打中的那只"(lib/victim)
#   ④ 挑"我的、且离它 8 格内"的雷楔 -> strike
# 【★ 为什么要判 zx.twg_own ★】场上可能同时有别人放的雷楔(不同使用者各一只)。
#   只按"8 格内"找会选错人 —— 那等于让别人的雷楔替你打雷。
# ============================================================

# ⓪ 撤销自己的进度
advancement revoke @s only sweetdream:equipment/sword/thunder_wedge_hit

# ① 满蓄力闸
function sweetdream:lib/atk_charge
execute unless score @s zx.atk_ok matches 1 run return 0

# ② 手持判定(主手: 本件是剑, 平A只会用主手; 再加副手兜底与其它武器一致)
execute unless items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["thunder_wedge"]}] unless items entity @s weapon.offhand *[minecraft:custom_data~{zx:["thunder_wedge"]}] run return 0

# ③ 找出刚被自己打中的那只(last_hurt_by_player + HurtTime 两步收窄)
#   带 distance=0.. 显式锁维度(与 charge/hit、thunderclap/hit 一致, 见 RULES 坑 55)
function sweetdream:lib/victim
execute unless entity @e[tag=zx.victim,distance=0..,limit=1] run return 0

# ④ 我的 UUID[0](与 wedge_one 写进 zx.twg_own 的值同一来源)
scoreboard players set #twg_me zx.meta 0
execute store result score #twg_me zx.meta run data get entity @s UUID[0]

# ⑤ 以"命中位置"为基准, 找范围里属于我的雷楔 -> 由它落雷
#   ★ 先 `at @e[tag=zx.victim]` 再 `as @e[tag=zx.twg_wedge,distance=..8]`: at 定位置、
#     as 换身份, distance 才是"从被击者算 8 格"; 顺序反了会变成"从玩家算 8 格"。
#   ★ strike 里的 `~ ~ ~` 就是这里 at 出去的命中位置, 所以落雷点必然正确。
#   【两行: 原版 8 格 / 超限 12 格】选择器没法读 marker 上的半径, 只能按标签分两路。
#     两路必须**互斥**(一个判 unless、一个判 if 同一个标签), 否则超限那只在 8 格内
#     会被落两次雷。
execute at @e[tag=zx.victim,distance=0..,limit=1] as @e[type=marker,tag=zx.twg_wedge,distance=..8] if score @s zx.twg_own = #twg_me zx.meta unless entity @s[tag=zx.twg_ol] run function sweetdream:equipment/sword/thunder_wedge/strike
execute at @e[tag=zx.victim,distance=0..,limit=1] as @e[type=marker,tag=zx.twg_wedge,distance=..12] if score @s zx.twg_own = #twg_me zx.meta if entity @s[tag=zx.twg_ol] run function sweetdream:equipment/sword/thunder_wedge/strike

# ⑥ 摘掉临时标签
tag @e[tag=zx.victim] remove zx.victim
