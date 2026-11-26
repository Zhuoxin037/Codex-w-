# ============================================================
# fallendream:equipment/sword/tinder/dark —— 熄灭态: 反噬自己 + 点燃自己
# ------------------------------------------------------------
# 【谁调用它】tinder/hit(熄灭态分支)
# 【执行者】施法者(玩家)
# 【两步】① 对**自身**造成 最大生命值 ×0.3 的伤害。② 使「火种」变为燃烧状态。
# 【伤害怎么算】读面板最大生命(manacore:api/stats/get key=max_health, 出参 ×100),
#   ×0.3 = 面板值 ×3 / 1000(整数, 精度足够)。用 api/damage 打自己(target="@s")。
# ============================================================

# 钉死被击者(这里只用它确认"确实打到了生物")
function fallendream:lib/victim
execute unless data storage zx:victim context.vx_uuid run return 0
data modify storage zx:work vx_frames append value {context:{}}
data modify storage zx:work vx_frames[-1].context set from storage zx:victim context
function fallendream:equipment/sword/tinder/dark/victim_body with storage zx:work vx_frames[-1].context
data modify storage zx:victim context set from storage zx:work vx_frames[-1].context
data remove storage zx:work vx_frames[-1]
