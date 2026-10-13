# ============================================================
# sweetdream:equipment/bow/cloudtrail/apply —— 取射手 uuid, 转交 fire(宏)
# ------------------------------------------------------------
# 【宏参数】zx:work ct {target, shooter}
# 【执行者】被打中的那只生物(由 hook_victim 送进来)
# 【为什么要分两层宏】领域是"按 owner 认人的"(marker 的 data.zx.uu 存射手 uuid 文本),
#   所以必须先拿到射手 uuid 文本才能拼出 `data:{zx:{uu:"…"}}` 这个匹配条件。
#   fire 里那句匹配带 $(uuid), 只能在宏函数里写。
# 【射手下线】uuid 取不到就直接收工(不结算), 不报错也不会打到别人。
# ============================================================

$execute as $(shooter) run function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0
data modify storage zx:work ct.uuid set from storage zx:data self.uuid
$execute as $(shooter) at @s run function sweetdream:equipment/bow/cloudtrail/fire with storage zx:work ct
