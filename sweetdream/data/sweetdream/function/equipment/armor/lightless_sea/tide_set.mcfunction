# ============================================================
# sweetdream:equipment/armor/lightless_sea/tide_set —— 套装伤害: 反查释放者
# ------------------------------------------------------------
# 【宏参数】u0..u3(释放者 UUID 的四个 32 位 int,
#   由调用处 `with entity @s data.zx.ls` 绑定 —— 键名必须和 data.zx.ls 一致)
# 【为什么用宏拼选择器】UUID 文本没法写进选择器, 四个 int 可以 ——
#   和 internal/damage/deal 的归属反查同款手法。
# 【反查不到(释放者离线)】execute 选 0 人 → tide_go 不跑, 这次伤害静默跳过。
#   暗潮只有 8 秒寿命, 可接受。
# ============================================================

$execute as @a[nbt={UUID:[I;$(u0),$(u1),$(u2),$(u3)]},limit=1] run function sweetdream:equipment/armor/lightless_sea/tide_go
