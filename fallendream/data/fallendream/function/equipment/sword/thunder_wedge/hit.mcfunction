# ============================================================
# fallendream:equipment/sword/thunder_wedge/hit —— 雷楔 · 平A命中结算(被动「雷楔」)
# ------------------------------------------------------------
# 【谁调用它】进度 fallendream:equipment/sword/thunder_wedge_hit
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
advancement revoke @s only fallendream:equipment/sword/thunder_wedge_hit

# ① 满蓄力闸
function fallendream:lib/atk_charge
execute unless score @s zx.atk_ok matches 1 run return 0

# ② 手持判定(主手: 本件是剑, 平A只会用主手; 再加副手兜底与其它武器一致)
execute unless items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["thunder_wedge"]}] unless items entity @s weapon.offhand *[minecraft:custom_data~{zx:["thunder_wedge"]}] run return 0

# ③ 找出刚被自己打中的那只(last_hurt_by_player + HurtTime 两步收窄)
#   带 distance=0.. 显式锁维度(与 charge/hit、thunderclap/hit 一致, 见 RULES 坑 55)
function fallendream:lib/victim
execute unless data storage zx:victim context.vx_uuid run return 0
data modify storage zx:work vx_frames append value {context:{}}
data modify storage zx:work vx_frames[-1].context set from storage zx:victim context
function fallendream:equipment/sword/thunder_wedge/hit/victim_body with storage zx:work vx_frames[-1].context
data modify storage zx:victim context set from storage zx:work vx_frames[-1].context
data remove storage zx:work vx_frames[-1]
