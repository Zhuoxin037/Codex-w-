# ============================================================
# sweetdream:equipment/axe/deep_brine/hit_go —— 重溟被动主体
# ------------------------------------------------------------
# 【技能原文(必须和这里对上)】
#   "每次普通攻击命中了附有「渊海」的生物后，额外造成一次相当于自身最大魔力值
#    ×0.05 的伤害，并使其获得 2 秒缓慢Ⅲ。该效果对同一个生物 10 秒内最多触发一次。"
# 【【执行者】动手的玩家
# 【四步】
#   ① 钉死刚打中的那只(lib/victim)
#   ② 它带「渊海」吗? 不带就收工
#   ③ 逐目标节流: 同一只 10 秒内只触发一次(见 passive_gate)
#   ④ 算伤(最大魔力 ×0.05) -> 打它 -> 2 秒缓慢Ⅲ
# 【★ 节流为什么必须在生物身上 ★】文案是"对**同一个生物** 10 秒内最多触发一次";
#   记在玩家身上挡不住"换一只接着打"。
# 【★ 缓慢的 amplifier ★】缓慢Ⅲ = amplifier 2(Ⅰ=0)。用原版效果(带尾随 true 隐藏粒子),
#   与「渊海」附着时给的缓慢Ⅱ 互不冲突: 同 id 效果取等级高者、时长短者覆盖 —— 这里
#   命中瞬间给 Ⅲ 正好压过 mark_one 的 Ⅱ(2026-10-16 实装口径)。
# ============================================================

# ① 钉死刚被自己打中的那只(lib/victim: last_hurt_by_player + HurtTime 反查)
function sweetdream:lib/victim
execute unless data storage zx:victim context.vx_uuid run return 0
data modify storage zx:work vx_frames append value {context:{}}
data modify storage zx:work vx_frames[-1].context set from storage zx:victim context
function sweetdream:equipment/axe/deep_brine/hit_go/victim_body with storage zx:work vx_frames[-1].context
data modify storage zx:victim context set from storage zx:work vx_frames[-1].context
data remove storage zx:work vx_frames[-1]
