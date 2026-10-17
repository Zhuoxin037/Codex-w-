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

# ① 穿着门控（头盔）
execute unless items entity @s armor.head *[minecraft:custom_data~{zx:["backlight"]}] run return 0

# ② 已持有「回照」→ 不触发（文案"若自身未持有「回照」"）
execute if score @s zx.bk_wd >= #now manacore.meta run return 0

# ③ 20 秒节流（zx.bk_cd = 下次可触发刻）
scoreboard players add @s zx.bk_cd 0
execute if score @s zx.bk_cd > #now manacore.meta run return 0

# ④ 钉死刚被自己打中的那只
function sweetdream:lib/victim
execute unless entity @e[tag=zx.victim,distance=0..,limit=1] run return 0

# ⑤ 它带「夜火」吗？不带就收工
execute as @e[tag=zx.victim,distance=0..,limit=1] unless entity @s[tag=zx.status.yehuo] run tag @e[tag=zx.victim] remove zx.victim
execute unless entity @e[tag=zx.victim,distance=0..,limit=1] run return 0

# ⑥ 消耗它的「夜火」
data modify storage zx:work a set value {target:"@e[tag=zx.victim,distance=0..,limit=1]",mark:"yehuo",by:"@s",src:"equip"}
function sweetdream:lib/mark_consume

# ⑦ 被「永恒」补回来了 → 不算消耗，不给「回照」
tag @e[tag=zx.victim] remove zx.victim
execute if data storage zx:work mc{done:1b} run return 0

# ⑧ 获得「回照」5 秒（100 刻）
scoreboard players operation @s zx.bk_wd = #now manacore.meta
scoreboard players add @s zx.bk_wd 100

# ⑨ 20 秒节流记账（400 刻）
scoreboard players operation @s zx.bk_cd = #now manacore.meta
scoreboard players add @s zx.bk_cd 400

# ⑩ 表现：头盔位置闪一圈暖光，提示"回照已就绪"
execute at @s run particle minecraft:dust{color:[1.0,0.85,0.45],scale:1.4} ~ ~1.5 ~ 0.35 0.3 0.35 0.02 14 normal
execute at @s run particle minecraft:end_rod ~ ~1.6 ~ 0.2 0.2 0.2 0.02 4 normal
execute at @s run playsound minecraft:block.amethyst_block.chime player @a ~ ~ ~ 0.6 1.8
