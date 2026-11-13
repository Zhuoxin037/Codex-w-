# ============================================================
# sweetdream:equipment/sword/tinder/burn —— 燃烧态: 打一圈 + 点燃未燃者 + 熄灭自己
# ------------------------------------------------------------
# 【谁调用它】tinder/hit(燃烧态分支)
# 【执行者】施法者(玩家); 【分档】#td_ol(0=原版 / 1=超限, 由 hit -> is_ol 拍好)
# 【三步(顺序即技能原文顺序)】
#   ① 对"被击者 N 格内的全部生物"打 伤害(other_mul = 当前魔力 / max_mana_mul = 最大魔力)。
#   ② 使这些生物里**未处于燃烧状态**的燃烧 5 秒(原版 Fire = 100 tick)。
#   ③ 熄灭该武器(zx.td_on = 0) —— ★ **两版共用**: 超限原文那句
#      "…燃烧 5 秒并熄灭该武器，且使附有「夜火」…" 里的"并熄灭该武器"原稿**漏写**,
#      2026-10-12 用户确认补回 ⇒ 超限版打一发同样熄灭(与基础版一致)。
# 【超限另加】④ 使附有「夜火」(zx.status.yehuo) 的生物**额外受到一次**同样的伤害。
# 【★ at 必须在 as 前 ★】execute at @e[victim] as @e[范围] —— as 只换执行者不改坐标。
# ============================================================

# 钉死被击者
function sweetdream:lib/victim
execute unless data storage zx:victim context.vx_uuid run return 0
data modify storage zx:work vx_frames append value {context:{}}
data modify storage zx:work vx_frames[-1].context set from storage zx:victim context
function sweetdream:equipment/sword/tinder/burn/victim_body with storage zx:work vx_frames[-1].context
data modify storage zx:victim context set from storage zx:work vx_frames[-1].context
data remove storage zx:work vx_frames[-1]
