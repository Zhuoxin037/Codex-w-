# ============================================================
# sweetdream:equipment/staff/wind_ontheground/aura_self —— 每秒入口的取 UUID 层
# ------------------------------------------------------------
# 【谁调用它】second 里用 @a[scores={zx.wg_aura=1..}] 筛出来的人
# 【为什么要拆】aura_tick 里有按 UUID 拼的存储路径, 只能用宏;
#   而宏变量只能通过 with storage 传进宏函数 —— 所以这里先把 UUID 取到手。
# ============================================================

function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail
data modify storage zx:work wg.uuid set from storage zx:data self.uuid
function sweetdream:equipment/staff/wind_ontheground/aura_tick with storage zx:work wg
