# ============================================================
# sweetdream:equipment/bow/cold_crow/apply —— 取出"射手这一发"的数据(宏 {target,shooter})
# ------------------------------------------------------------
# 【执行者】被打中的那只生物
# 【为什么要分两层宏】数据挂在射手名下(zx:data cc."<uuid>"), 路径里要用 uuid 字符串,
#   所以先借 lib/uuid 把射手的 uuid 取出来, 再交给 fire 开工。
# 【射手下线】uuid 取不到就直接收工(不打伤害), 不报错也不会打到别人。
# ============================================================

$execute as $(shooter) run function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0
data modify storage zx:work cc.uuid set from storage zx:data self.uuid
function sweetdream:equipment/bow/cold_crow/fire with storage zx:work cc
