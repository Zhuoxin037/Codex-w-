# ============================================================
# fallendream:equipment/armor/crimson_seam/ol_arm —— 超限·绯缝：平A 命中带「噬心」者 -> 挂"下一次真伤"
# ------------------------------------------------------------
# 【谁调它】进度 fallendream:equipment/armor/crimson_seam_ol_hit（player_hurt_entity，只认平A）
# 【执行者】动手的那个玩家
# 【文案(逐字)】"若自身当前生命值高于 80% ，则若自身未触发本装备以下效果时攻击附有
#   「噬心」的生物时消耗「噬心」，使自身下一次普通近战伤害额外造成一次相等的真实伤害。"
# 【★ 两件事共用一个进度 ★】① 已经挂着"下一次"时，这一刀先兑现追加真伤并清空;
#   ② 否则才走"高血 + 目标带噬心 → 消耗 + 挂下一次"。这样"下一次"一定会被下一次平A
#   用到，不会额外造一个进度。
# 【★ 待用户确认的口径 ★】"相等"按**玩家面板基础攻击力**算 —— 原版平A 的数值不经过
#   本包的 internal/damage/one，进度回调拿不到那一刀的实际伤害数，只能用面板值代替。
#   "未触发本装备以下效果"按 6 秒节流实现（基础版回血也是 6 秒）。
# ============================================================

advancement revoke @s only fallendream:equipment/armor/crimson_seam_ol_hit

# ① 已有待发的追加真伤 -> 先兑现（并且这一刀不再重新挂）
execute if score @s zx.cr_ol_next matches 1 unless data storage zx:combat events[-1].event{kind:"melee"} run return 0
execute if score @s zx.cr_ol_next matches 1 run return run function fallendream:equipment/armor/crimson_seam/ol_extra

# ② 门槛：穿超限绯缝 + 血量 > 80% + 6 秒闸
execute unless items entity @s armor.chest *[minecraft:custom_data~{zx:["crimson_seam"],ol:"crimson_seam"}] run return 0
function fallendream:lib/hp_pct
execute if score #hp_p100 zx.meta matches ..8000 run return 0

# ③ 找"刚打的那一只" -> 宏叶子里判噬心并消耗（宏参数要固化，走 vx_frames 快照）
function fallendream:lib/victim
execute unless data storage zx:victim context.vx_uuid run return 0
data modify storage zx:work vx_frames append value {context:{}}
data modify storage zx:work vx_frames[-1].context set from storage zx:victim context
function fallendream:equipment/armor/crimson_seam/ol_arm_hit with storage zx:work vx_frames[-1].context
data modify storage zx:victim context set from storage zx:work vx_frames[-1].context
data remove storage zx:work vx_frames[-1]
