# ============================================================
# sweetdream:equipment/armor/withered_garden/wood_set —— 朽木伤害: 反查释放者
# ------------------------------------------------------------
# 【宏参数】u0..u3(释放者 UUID 的四个 32 位 int,
#   由调用处 `with entity @s data.zx.gd` 绑定 —— 键名必须和 data.zx.gd 一致)
# 【为什么用宏拼选择器】UUID 文本没法写进选择器, 四个 int 可以 ——
#   和 internal/damage/deal 的归属反查同款手法。
# 【反查不到(释放者离线)】execute 选 0 人 → wood_go 不跑, 这次伤害静默跳过。
#   朽木只有 8 秒寿命, 可接受。
# ============================================================

$data modify storage zx:work ub set value {u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}
function sweetdream:lib/u_by
execute as @a[tag=zx.ub,limit=1] run function sweetdream:equipment/armor/withered_garden/wood_go
