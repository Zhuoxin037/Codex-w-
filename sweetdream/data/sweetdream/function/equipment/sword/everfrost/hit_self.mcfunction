# ============================================================
# sweetdream:equipment/sword/everfrost/hit_self —— 以"等结算的玩家"身份取 UUID
# ------------------------------------------------------------
# 【谁调用它】lib/second: execute as @a[tag=zx.ef_casting] at @s run function ...
# 【形态照抄流光 hit_self】必须 with storage zx:work <临时节点> 交给宏层,
#   直接传 zx:data self 会让宏函数一条命令都不跑(静默)。
# ============================================================

function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail
data modify storage zx:work ef set value {uuid:""}
data modify storage zx:work ef.uuid set from storage zx:data self.uuid
function sweetdream:equipment/sword/everfrost/hit_due with storage zx:work ef
