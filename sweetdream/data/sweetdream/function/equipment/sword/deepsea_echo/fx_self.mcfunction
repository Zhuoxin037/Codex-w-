# ============================================================
# sweetdream:equipment/sword/deepsea_echo/fx_self —— 取 UUID 交给宏层
# ------------------------------------------------------------
# 【为什么拆两层】"源"的标记名里带施法者 UUID, 拼路径只能用宏变量,
#   而宏变量只能通过 with storage 传进宏函数。
# ============================================================

function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail
data modify storage zx:work de.uuid set from storage zx:data self.uuid
function sweetdream:equipment/sword/deepsea_echo/fx_go with storage zx:work de
