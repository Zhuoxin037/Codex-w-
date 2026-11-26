# ============================================================
# fallendream:equipment/sword/blood_loss/hit_go —— 失血: 消耗「噬心」积攒「心血」
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
function fallendream:lib/victim
execute unless data storage zx:victim context.vx_uuid run return 0
data modify storage zx:work vx_frames append value {context:{}}
data modify storage zx:work vx_frames[-1].context set from storage zx:victim context
function fallendream:equipment/sword/blood_loss/hit_go/victim_body with storage zx:work vx_frames[-1].context
data modify storage zx:victim context set from storage zx:work vx_frames[-1].context
data remove storage zx:work vx_frames[-1]
