# ============================================================
# sweetdream:equipment/armor/gyre/hit —— 回旋 ·「旋步」兑现（近战命中触发）
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:equipment/armor/gyre_hit（player_hurt_entity，只算平A）
# 【执行者】动手的玩家
# 【技能原文（lore 逐字）】
#   "「旋步」：下一次普通近战命中生物后消耗「旋步」，使自身呈圆形轨迹移动至命中生物
#    的背后，并对本次命中的生物额外造成一次 24 点固定伤害，对移动过程中碰到的生物
#    造成一次 30 点固定伤害。遇到障碍即停。"
# 【★ 兑现顺序 ★】先"消耗旋步"（防同一刻重入），再钉目标、再算落点、再起步。
# 【★ 目标怎么钉 ★】lib/victim（同失血/返照）：进度不能把实体传进函数，靠
#   last_hurt_by_player + HurtTime 反查"刚才这一下打的是哪只"。
# 【★ 2026-10-17 改：绕后变成"有过程" ★】用户反馈旧版是瞬移。现在：
#   ① 这里一次性把三个落点算成 marker（zx.gyr_w1/w2/w3，角度 90°/150°/180°）；
#      —— 必须先算，因为角度基准是"命中那一刻玩家所在的方位"，玩家一动就歪。
#   ② 设 zx.gyr_st = 1，之后由 core/tick 每刻推 arc（7 刻内分三步绕到背后，收尾打 24 点）。
#      ★ 这里**不再**顺手调一次 arc ★ 状态号从 1 起，若同刻再调一次，core/tick 会在
#      下一克从 2 继续 ⇒ 第 1 段被跳过（直接从侧面开始）。删掉那次调用后，最多晚
#      1 刻（0.05 秒）起手，肉眼无感，但状态机永远只前进一步。
# ============================================================

# ⓪ 撤销自己的进度
advancement revoke @s only sweetdream:equipment/armor/gyre_hit
function sweetdream:lib/atk_charge
execute unless score @s zx.atk_ok matches 1 run return 0

# ① 穿着门控（护腿）
execute unless items entity @s armor.legs *[minecraft:custom_data~{zx:["gyre"]}] run return 0

# ② 没有「旋步」（或已过期）→ 收工
execute if score @s zx.gy_wd < #now manacore.meta run return 0

# ③ 消耗「旋步」
scoreboard players set @s zx.gy_wd 0

# ④ 钉死刚命中的那只
function sweetdream:lib/victim
execute unless data storage zx:victim context.vx_uuid run return 0
data modify storage zx:work vx_frames append value {context:{}}
data modify storage zx:work vx_frames[-1].context set from storage zx:victim context
function sweetdream:equipment/armor/gyre/hit/victim_body with storage zx:work vx_frames[-1].context
data modify storage zx:victim context set from storage zx:work vx_frames[-1].context
data remove storage zx:work vx_frames[-1]
