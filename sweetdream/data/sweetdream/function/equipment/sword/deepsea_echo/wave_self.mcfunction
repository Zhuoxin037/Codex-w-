# ============================================================
# sweetdream:equipment/sword/deepsea_echo/wave_self —— 以玩家身份取 UUID
# ------------------------------------------------------------
# 【为什么要拆两层】每个源的标记名里带施法者 UUID, 拼路径只能用宏变量,
#   而宏变量只能通过 with storage 传进宏函数。这一层先把 UUID 取到手,
#   再把 zx:work de(里面就是 uuid)整个当宏参数交给下一层。
# ============================================================

function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail
data modify storage zx:work de.uuid set from storage zx:data self.uuid
function sweetdream:equipment/sword/deepsea_echo/wave_go with storage zx:work de
