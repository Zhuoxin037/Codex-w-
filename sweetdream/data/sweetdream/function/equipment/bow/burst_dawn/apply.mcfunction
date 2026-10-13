# ============================================================
# sweetdream:equipment/bow/burst_dawn/apply —— 取出射手 uuid, 转交 fire(宏)
# ------------------------------------------------------------
# 【宏参数】zx:work bd {target, shooter, mode, uu}
# 【执行者】被打中的那只生物(由 hook_victim 送进来)
# 【为什么要分两层宏】面板基础攻击力 / 最大魔力 / 伤害归属都按**射手**算,
#   而射手只能靠标签 zx.bd_pl 找回。这里先把射手的 uuid 取出来(拼存储键要用
#   字符串), 再把 fire 整个放到 `as 射手 at 射手` 里跑 —— 于是 fire 里所有
#   "自身"都是射手。
# 【射手下线】uuid 取不到就直接收工(不打伤害), 不报错也不会打到别人。
# ============================================================

$execute as $(shooter) run function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0
data modify storage zx:work bd.uuid set from storage zx:data self.uuid
$execute as $(shooter) at @s run function sweetdream:equipment/bow/burst_dawn/fire with storage zx:work bd
