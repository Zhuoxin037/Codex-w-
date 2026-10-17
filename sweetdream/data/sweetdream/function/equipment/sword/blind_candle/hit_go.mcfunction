# ============================================================
# sweetdream:equipment/sword/blind_candle/hit_go —— 盲烛平A主体(被动 + 烛火)
# ------------------------------------------------------------
# 【技能原文(必须和这里对上)】
#   ✦ 被动技能
#   "每次普通攻击命中了附有「夜火」的生物后，对其 2.5 格内随机一个其他生物造成一次
#    相当于自身最大魔力值 ×0.06 的伤害。若其也附有「夜火」，则该伤害提高为自身最大
#    魔力值 ×0.1。该效果 5 秒内最多触发一次。"
#   ✦ 烛火(主动给的 8 秒状态)
#   "每次普通攻击后对目标 3 格内随机一个其他生物造成一次相当于自身最大魔力值 ×0.08
#    的伤害。若没有其他生物，则改为对被攻击的生物造成一次相当于自身最大魔力值 ×0.04
#    的伤害。"
# 【执行者】动手的玩家
# 【为什么把 victim 再拷成 zx.bcd_v】lib/victim 给的 zx.victim 是**全包共用**的临时标签,
#   后面任何一步(包括被动段自己)都可能把它清掉; 这一发要连跑两段, 先钉死一份本轮专用。
# 【两段互相独立】被动要"目标带夜火", 烛火只看"自己有没有烛火"; 段间不共享结论。
# ============================================================

# ① 钉死刚被自己打中的那只
function sweetdream:lib/victim
execute unless entity @e[tag=zx.victim,distance=0..,limit=1] run return 0
tag @e[tag=zx.bcd_v,distance=0..] remove zx.bcd_v
tag @e[tag=zx.victim,distance=0..,limit=1] add zx.bcd_v
tag @e[tag=zx.victim] remove zx.victim

# ② 被动段: 目标带「夜火」才结算(节流在 passive 里)
scoreboard players set #bcd_ye zx.meta 0
execute as @e[tag=zx.bcd_v,distance=0..,limit=1] if entity @s[tag=zx.status.yehuo] run scoreboard players set #bcd_ye zx.meta 1
execute if score #bcd_ye zx.meta matches 1 run function sweetdream:equipment/sword/blind_candle/passive

# ③ 烛火段(独立于夜火)
function sweetdream:equipment/sword/blind_candle/candle

# ④ 收尾: 清本轮临时标签
tag @e[tag=zx.bcd_v,distance=0..] remove zx.bcd_v
tag @e[tag=zx.bcd_pick,distance=0..] remove zx.bcd_pick
tag @e[tag=zx.bcd_pick2,distance=0..] remove zx.bcd_pick2
tag @e[tag=zx.bcd_hit2,distance=0..] remove zx.bcd_hit2
