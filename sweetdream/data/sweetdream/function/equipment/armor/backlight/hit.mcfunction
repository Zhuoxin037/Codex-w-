# ============================================================
# sweetdream:equipment/armor/backlight/hit —— 返照：近战命中带「夜火」的生物
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:equipment/armor/backlight_hit（player_hurt_entity，只算平A）
# 【执行者】动手的玩家
# 【技能原文（lore 逐字）】
#   "自身魔力值上限 +160。普通近战命中了附有「夜火」且仍存活的生物后，若自身未持有
#    「回照」，则消耗其「夜火」，为自身获得持续 5 秒的「回照」。该效果 20 秒内最多触发一次。"
# 【★ 三个判据的顺序不能换 ★】
#   ① "未持有回照" 排在**消耗之前** —— 一旦有回照就不该白扣别人的「夜火」；
#   ② "20 秒节流" 也排在消耗之前 —— 同理；
#   ③ "带夜火 + 仍存活" 用 lib/victim 钉死刚打中的那只再看标签：
#      进度在伤害结算**之后**才触发，被打死的目标已经从世界移除、标签也没了
#      ⇒ 判标签不成立，正好对上"且仍存活"（同失血/殓丝的口径）。
# 【★ 真消耗才算 ★】穿「永恒」时标签会被原地补回（mc.done = 1b）—— 那种情况
#   不算消耗，不给「回照」（同余烬/回潮扣/失血）。
# 【★ src:"equip" ★】这是**装备被动自己**顺手消耗的，不是"技能消耗"——
#   回潮扣/烛跬 那几件按 src 分流时不把它算进"技能消耗"。
# ============================================================

# ⓪ 撤销自己的进度（自撤销型进度首行必须 revoke）
advancement revoke @s only sweetdream:equipment/armor/backlight_hit
function sweetdream:lib/atk_charge
execute unless score @s zx.atk_ok matches 1 run return 0

# ① 穿着门控（头盔）
execute unless items entity @s armor.head *[minecraft:custom_data~{zx:["backlight"]}] run return 0

# ② 已持有「回照」→ 不触发（文案"若自身未持有「回照」"）
execute if score @s zx.bk_wd >= #now manacore.meta run return 0

# ③ 20 秒节流（zx.bk_cd = 下次可触发刻）
scoreboard players add @s zx.bk_cd 0
execute if score @s zx.bk_cd > #now manacore.meta run return 0

# ④ 钉死刚被自己打中的那只
function sweetdream:lib/victim
execute unless data storage zx:victim context.vx_uuid run return 0
data modify storage zx:work vx_frames append value {context:{}}
data modify storage zx:work vx_frames[-1].context set from storage zx:victim context
function sweetdream:equipment/armor/backlight/hit/victim_body with storage zx:work vx_frames[-1].context
data modify storage zx:victim context set from storage zx:work vx_frames[-1].context
data remove storage zx:work vx_frames[-1]
