# ============================================================
# sweetdream:equipment/axe/draught/strip —— 立即撤掉饮鸩的攻击力加成
# ------------------------------------------------------------
# 【谁调用它】draught/cast(⑤, 重入时先撤旧的) 与 draught/expire(到期时)
# 【执行者】玩家
# 【做什么】按账本 zx.dg_buf 的数值, 从面板 base_attack 里减回去(取负数走 stats/add)。
#   ★ scale 用 -1: `store result ... double -1` 直接得到负值。
# ============================================================

execute if score @s zx.dg_buf matches ..0 run return 0

data modify storage manacore:in arg set value {uuid:"",key:"base_attack",value:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute store result storage manacore:in arg.value double -1 run scoreboard players get @s zx.dg_buf
function manacore:api/stats/add

scoreboard players set @s zx.dg_buf 0
scoreboard players set @s zx.dg_on 0
