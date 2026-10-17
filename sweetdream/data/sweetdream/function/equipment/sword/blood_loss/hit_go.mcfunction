# ============================================================
# sweetdream:equipment/sword/blood_loss/hit_go —— 失血: 消耗「噬心」积攒「心血」
# ------------------------------------------------------------
# 【执行者】动手的玩家
# 【技能原文】"「心血」最多 3 层。普通近战命中了附有「噬心」且仍存活的生物后，
#   消耗其「噬心」，并为自身积攒 1 层「心血」。"
# 【★ "且仍存活" ★】进度在伤害结算**之后**触发: 被打死的那一只已经从世界移除、
#   它身上的「噬心」也没了 ⇒ 下面第一步判标签就不成立, 正好对上文案。
#   (同殓丝 on_true_hit 的口径。)
# 【★ 满 3 层就不再消耗 ★】文案"最多 3 层" ⇒ 满层时不能再动别人身上的「噬心」,
#   否则会白扣状态却不给层数。
# 【★ "真消耗"才算 ★】走 lib/mark_consume:穿「永恒」时标签会被原地补回
#   (mc.done = 1b) —— 那种情况不算消耗, 不给层数(同余烬/回潮扣的判据)。
# 【★ src:"equip" ★】这是**装备被动自己**顺手消耗的, 不是"技能消耗" ——
#   回潮扣/烛跬/杂纹 那几件按 src 分流时不把它算进"技能消耗"(见 mark_consume ①.5)。
# ============================================================

# ① 钉死刚被自己打中的那只
function sweetdream:lib/victim
execute unless entity @e[tag=zx.victim,distance=0..,limit=1] run return 0

# ② 它带「噬心」吗? 不带就收工
execute as @e[tag=zx.victim,distance=0..,limit=1] unless entity @s[tag=zx.status.shixin] run tag @e[tag=zx.victim] remove zx.victim
execute unless entity @e[tag=zx.victim,distance=0..,limit=1] run return 0

# ③ 已经满 3 层 -> 收工(不白扣别人的「噬心」)
scoreboard players add @s zx.bld_n 0
execute if score @s zx.bld_n matches 3.. run tag @e[tag=zx.victim] remove zx.victim
execute if score @s zx.bld_n matches 3.. run return 0

# ④ 消耗它身上的「噬心」
data modify storage zx:work a set value {target:"@e[tag=zx.victim,distance=0..,limit=1]",mark:"shixin",by:"@s",src:"equip"}
function sweetdream:lib/mark_consume

# ⑤ 被「永恒」补回来了 -> 不算消耗, 不给层数
execute if data storage zx:work mc{done:1b} run tag @e[tag=zx.victim] remove zx.victim
execute if data storage zx:work mc{done:1b} run return 0

# ⑥ 积攒 1 层「心血」
scoreboard players add @s zx.bld_n 1

# ⑦ 表现: 心血浮上来一层
execute at @s run particle minecraft:dust{color:[0.6,0.02,0.05],scale:1.2} ~ ~1.2 ~ 0.3 0.3 0.3 0.02 8 normal
execute at @s run playsound minecraft:entity.player.breath player @a ~ ~ ~ 0.5 0.7

# ⑧ 收尾
tag @e[tag=zx.victim] remove zx.victim
