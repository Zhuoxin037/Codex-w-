# ============================================================
# sweetdream:equipment/sword/liuguang/ol_hit_self —— 以"等结算的玩家"身份取 UUID
# ------------------------------------------------------------
# 【谁调用它】lib/second 每秒: execute as @a[tag=zx.lgo_casting] at @s run ...
# 【为什么拆两层】标记名字里带的是玩家 UUID, 拼路径只能用宏变量,
#   而宏变量只能通过 with storage 传 —— 所以这一层先取 UUID 抄进临时节点。
#   ⚠️ 别把 zx:data self 直接当宏参数传(实测那样宏函数一条命令都不跑, 静默)。
# ============================================================

function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail
data modify storage zx:work lgo set value {uuid:""}
data modify storage zx:work lgo.uuid set from storage zx:data self.uuid
function sweetdream:equipment/sword/liuguang/ol_hit_due with storage zx:work lgo
