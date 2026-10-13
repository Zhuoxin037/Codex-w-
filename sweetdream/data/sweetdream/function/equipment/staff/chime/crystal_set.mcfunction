# ============================================================
# sweetdream:equipment/staff/chime/crystal_set —— 共鸣水晶伤害: 反查释放者(宏)
# ------------------------------------------------------------
# 【宏参数】u0..u3(释放者 UUID 的四个 32 位 int; 调用处 `with entity @s data.zx.ch`)、
#           ol(这颗水晶是不是超限召唤的)
# 【执行者】水晶 marker; 【位置】水晶处
# 【为什么用宏拼选择器】UUID 文本没法写进选择器, 四个 int 可以 ——
#   和朽木 wood_set 完全同款的手法。
# 【反查不到(释放者离线)】execute 选 0 人 -> crystal_go 不跑, 这次伤害静默跳过。
#   水晶只有 8(超限 18) 秒寿命, 可接受。
# 【位置会保留】`as` 只换执行者、不换坐标 -> crystal_go 里坐标仍是水晶处,
#   所以 6 格内的判定圆心就是水晶。
# 【超限分档】每 2 秒那一段的倍率 0.03 -> 0.05 —— 按水晶自己的 ol 现填进宏节点。
# ============================================================

# ① 倍率: 原版 0.03 / 超限 0.05
data modify storage zx:work chc.mm set value 0.03
execute if data entity @s data.zx.ch{ol:1} run data modify storage zx:work chc.mm set value 0.05

# ② 反查释放者 -> 交给他结算
$execute as @a[nbt={UUID:[I;$(u0),$(u1),$(u2),$(u3)]},limit=1] run function sweetdream:equipment/staff/chime/crystal_go with storage zx:work chc
