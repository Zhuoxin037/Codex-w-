# ============================================================
# fallendream:equipment/armor/crimson_seam/ol_extra —— 超限·绯缝：兑现"下一次平A的追加真伤"
# ------------------------------------------------------------
# 【谁调它】crimson_seam/ol_arm ①（同一次进度回调，执行者 = 玩家）
# 【★ 先清标记再打 ★】不清的话追加真伤那一下本身又是平A 事件（虽然不是 is_player_attack），
#   或者下一次平A 会再打一次 —— 文案是"下一次"，只允许一次。
# ============================================================

scoreboard players set @s zx.cr_ol_next 0
function fallendream:lib/victim
execute unless data storage zx:victim context.vx_uuid run return 0
data modify storage zx:work vx_frames append value {context:{}}
data modify storage zx:work vx_frames[-1].context set from storage zx:victim context
function fallendream:equipment/armor/crimson_seam/ol_extra_hit with storage zx:work vx_frames[-1].context
data modify storage zx:victim context set from storage zx:work vx_frames[-1].context
data remove storage zx:work vx_frames[-1]
