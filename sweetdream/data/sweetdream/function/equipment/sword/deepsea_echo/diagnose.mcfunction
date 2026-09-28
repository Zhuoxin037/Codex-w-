# ============================================================
# sweetdream:equipment/sword/deepsea_echo/diagnose —— 深海的回响自检
# ------------------------------------------------------------
# 【用法】/function sweetdream:equipment/sword/deepsea_echo/diagnose
# 【为什么要拆两层】有几项要按 UUID 拼路径(状态、源标记), 只能用宏
# ============================================================

tellraw @s [{"text":"===== 深海的回响自检 =====","color":"gold"}]

function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail
data modify storage zx:work de.uuid set from storage zx:data self.uuid
function sweetdream:equipment/sword/deepsea_echo/diagnose_go with storage zx:work de
