# ============================================================
# sweetdream:equipment/sword/liuguang/hit_self —— 以"等结算的玩家"身份取 UUID
# ------------------------------------------------------------
# 【谁调用它】hit 用 execute as @a[tag=zx.lg_casting] 对它执行
# 【为什么拆两层】标记名字里带的是玩家 UUID, 拼路径只能用宏变量,
#   而宏变量只能通过 with storage 传进宏函数 —— 所以这一层先取 UUID,
#   再抄进一个临时节点交给下一层。
#   ⚠️ 2026-10-03 修: 原来直接把 `zx:data self` 当宏参数传, 实测那样
#      **hit_due 一条命令都不跑**(静默, 日志都不报)。全项目能正常工作的
#      调用都是 `with storage zx:work <临时节点>`, 照这个形态来。
# ============================================================

function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail
data modify storage zx:work lg set value {uuid:""}
data modify storage zx:work lg.uuid set from storage zx:data self.uuid
function sweetdream:equipment/sword/liuguang/hit_due with storage zx:work lg
