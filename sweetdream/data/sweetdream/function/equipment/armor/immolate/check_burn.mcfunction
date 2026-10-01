# ============================================================
# sweetdream:equipment/armor/immolate/check_burn —— 检查单只生物是否在燃烧
# ------------------------------------------------------------
# 【执行者】被扫描到的生物
# 【谁调用它】immolate/tick 每 tick 对玩家 12 格内的实体逐个调用
# 【为什么不用 @e[nbt={Fire:1..}]】
#   1.21.5 的实体选择器里 `nbt={Fire:1..}` 会报“应为十进制数”，
#   整条 tick 函数直接加载失败。这里改成最笨但最稳的 data get。
# ============================================================

# 先把 #im_f 清 0: 万一 data get 失败/没这个字段, 也不会留下上一只生物的旧值。
scoreboard players set #im_f zx.meta 0
execute store result score #im_f zx.meta run data get entity @s Fire
execute if score #im_f zx.meta matches 1.. run scoreboard players set #im_burn_found zx.meta 1
