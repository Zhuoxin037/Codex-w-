# ============================================================
# fallendream:equipment/axe/agony/hit —— 苦痛·超限：转移窗口内的命中
# ------------------------------------------------------------
# 【谁调用它】进度 fallendream:equipment/axe/agony_hit（player_hurt_entity）
# 【门控】zx.ag_xfer > #now 才往下走 —— 没开窗时这一行就是全部开销。
# 【★ 被进度直接引用 ⇒ 本文件不能有宏行 ★】取值 + 派发留给 xfer（with storage）。
# ============================================================

advancement revoke @s only fallendream:equipment/axe/agony_hit

execute unless score @s zx.ag_xfer > #now manacore.meta run return 0

function fallendream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0
function fallendream:lib/victim
execute unless data storage zx:victim context.vx_uuid run return 0

data modify storage zx:work agq set value {u:"",my:""}
data modify storage zx:work agq.u set from storage zx:victim context.vx_uuid
data modify storage zx:work agq.my set from storage zx:data self.uuid
function fallendream:equipment/axe/agony/xfer with storage zx:work agq
