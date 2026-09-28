# ============================================================
# sweetdream:equipment/sword/liuguang/hit_self —— 以"等结算的玩家"身份取 UUID
# ------------------------------------------------------------
# 【谁调用它】hit 用 execute as @a[tag=zx.lg_casting] 对它执行
# 【为什么要拆两层】标记名字里带的是玩家 UUID, 拼路径只能用宏变量,
#   而宏变量只能通过 with storage 传进宏函数 —— 所以这一层先取 UUID
#   (lib/uuid 会把结果写进 zx:data self), 再把 self 整个当宏参数交给下一层。
# ============================================================

function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail
function sweetdream:equipment/sword/liuguang/hit_due with storage zx:data self
