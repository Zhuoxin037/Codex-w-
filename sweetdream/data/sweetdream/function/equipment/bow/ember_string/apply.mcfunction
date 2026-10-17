# ============================================================
# sweetdream:equipment/bow/ember_string/apply —— 取出射手 uuid, 转交 fire(宏)
# ------------------------------------------------------------
# 【宏参数】zx:work es {target, shooter}
# 【执行者】被打中的那只生物(由 hook_victim 送进来)
# 【为什么分两层】伤害要按**射手**的最大魔力值算 -> 只能反查射手(标签 zx.es_pl),
#   拿到 uuid 后再把 fire 放进 `as 射手 at 射手` 里跑。
# ============================================================

$execute as $(shooter) run function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0
data modify storage zx:work es.uuid set from storage zx:data self.uuid
$execute as $(shooter) at @s run function sweetdream:equipment/bow/ember_string/fire with storage zx:work es
