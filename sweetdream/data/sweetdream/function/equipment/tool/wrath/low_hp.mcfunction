# ============================================================
# sweetdream:equipment/tool/wrath/low_hp —— 出参: 自身血量是否低于 20%
# ------------------------------------------------------------
# 【出参】#wr_hp zx.meta = 当前生命×500 − 生命上限×100
#   < 0(即 matches ..-1) = 血量**低于** 20%; >= 0 = 不低于。
#   (判定方式: hp < 0.2×max ⇔ hp×500 < max×100 ⇔ 当前生命×500 − 生命上限×100 < 0)
#   ★ 2026-10-06 修: 上一版写成 hp×100 − max×100, 那等价于 hp < max
#     —— **只要掉一点血就成立**, 于是愠怒变成"受伤即触发", 而面板上看不出来。
#     等价写法也可以是 max×20(hp×100 < max×20), 这里用 ×5 少一次除法取整。
# 【为什么不用谓词】原版 predicate 没有"血量百分比"条件(entity_properties 的
#   nbt 只能精确匹配, 不支持区间) ⇒ 只能自己算。这里做一个共用件,
#   愠怒的每秒续抗性(wrath/second)与伤害乘区(wrath/hook_calc)都用它。
# 【★ 定点只乘 100, 不乘 1000 ★】`data get ... 100` 的结果是整数,
#   store 进计分项正好; 属性那一路要先用 storage 中转(constant scale),
#   因为 `execute store result score` **没有** scale 参数(scale 是 data get 自己的)。
# 【★ 为什么先写 {mh:0.0} ★】`store result storage` 在源命令失败时**不写盘**,
#   会留着上一次的旧值; 先抹一遍才能保证读到的是"这一次"的。
# ============================================================

scoreboard players set #wr_hp zx.meta 0
execute store result score #wr_hp zx.meta run data get entity @s Health 100

data modify storage zx:work wr set value {mh:0.0}
execute store result storage zx:work wr.mh double 100 run attribute @s minecraft:max_health get

scoreboard players set #wr_mh zx.meta 0
execute store result score #wr_mh zx.meta run data get storage zx:work wr.mh

# ★ 先 ×5: 把"当前生命×100"抬成"×500", 才和"生命上限×100"同一个 20% 基准
scoreboard players operation #wr_hp zx.meta *= #5 zx.meta
scoreboard players operation #wr_hp zx.meta -= #wr_mh zx.meta
