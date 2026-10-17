# ============================================================
# sweetdream:equipment/bow/feather_sleep/apply —— 取出射手 uuid, 转交 fire(宏)
# ------------------------------------------------------------
# 【宏参数】zx:work fs {target, shooter}
# 【执行者】被打中的那只生物(由 hook_victim 送进来)
# 【为什么要分两层宏】"自身最大魔力值 / 攻击力"都要按**射手**算, 而射手只能靠
#   标签 zx.fs_pl 找回。这里先把射手 uuid 取出来(拼存储键要用字符串), 再把 fire
#   整个放进 `as 射手 at 射手` 里跑 —— 于是 fire 里所有"自身"都是射手。
# 【射手下线】uuid 取不到就直接收工(不消白昼梦、不放羽箭), 不报错也不会打到别人。
# ============================================================

$execute as $(shooter) run function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0
data modify storage zx:work fs.uuid set from storage zx:data self.uuid
$execute as $(shooter) at @s run function sweetdream:equipment/bow/feather_sleep/fire with storage zx:work fs
