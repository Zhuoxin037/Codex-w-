# ============================================================
# sweetdream:equipment/sword/rogue_star/hit_self —— 以"等结算的玩家"身份取 UUID
# ------------------------------------------------------------
# 【谁调用它】lib/second: execute as @a[tag=zx.rs_casting] at @s run function ...
# 【为什么拆两层】记录路径 zx:data rs."<uuid>" 里的 uuid 要用宏变量拼,
#   而宏变量只能 with storage 传进宏函数 —— 所以这层先取 uuid, 再抄进临时节点交下一层。
#   ⚠️ 照流光 hit_self 的形态来: 必须 with storage zx:work <临时节点>,
#      直接传 zx:data self 会让宏函数一条命令都不跑(静默)。
# ============================================================

function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail
data modify storage zx:work rs set value {uuid:""}
data modify storage zx:work rs.uuid set from storage zx:data self.uuid
function sweetdream:equipment/sword/rogue_star/hit_due with storage zx:work rs
