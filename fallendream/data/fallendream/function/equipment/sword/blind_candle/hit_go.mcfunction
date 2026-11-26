# ============================================================
# fallendream:equipment/sword/blind_candle/hit_go —— 盲烛平A主体(被动 + 烛火)
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
function fallendream:lib/victim
execute unless data storage zx:victim context.vx_uuid run return 0
data modify storage zx:work vx_frames append value {context:{}}
data modify storage zx:work vx_frames[-1].context set from storage zx:victim context
function fallendream:equipment/sword/blind_candle/hit_go/victim_body with storage zx:work vx_frames[-1].context
data modify storage zx:victim context set from storage zx:work vx_frames[-1].context
data remove storage zx:work vx_frames[-1]
