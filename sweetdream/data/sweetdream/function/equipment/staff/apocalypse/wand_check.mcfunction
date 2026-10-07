# ============================================================
# sweetdream:equipment/staff/apocalypse/wand_check —— 快捷栏是否持有启示录
# ------------------------------------------------------------
# 【谁调用它】core/tick(每刻, execute as @a; 执行者 = 玩家)
# 【为什么用 tag 而不是两处各写一遍】判定("快捷栏 0-8 任一槽有启示录")要展开
#   9 个槽; tick 的 snap 和 observe 的记页都得用**同一个**结果 —— 用
#   zx.ap_has 标签一次算好两处读, 还能保证"快照条件 == 记页条件"(不一致会让
#   ap_pre 读到陈旧值, 记页算成巨大错误数)。
# 【为什么是 9 个槽】items 谓词没有"整段快捷栏"的槽名; `hotbar` 裸写是非法槽位
#   (2026-10-05 真实报错: 未知的槽位"hotbar")。只能 hotbar.0..8 逐槽展开。
# ============================================================

tag @s remove zx.ap_has
execute if items entity @s hotbar.0 *[custom_data~{zx:["apocalypse"]}] run tag @s add zx.ap_has
execute if items entity @s hotbar.1 *[custom_data~{zx:["apocalypse"]}] run tag @s add zx.ap_has
execute if items entity @s hotbar.2 *[custom_data~{zx:["apocalypse"]}] run tag @s add zx.ap_has
execute if items entity @s hotbar.3 *[custom_data~{zx:["apocalypse"]}] run tag @s add zx.ap_has
execute if items entity @s hotbar.4 *[custom_data~{zx:["apocalypse"]}] run tag @s add zx.ap_has
execute if items entity @s hotbar.5 *[custom_data~{zx:["apocalypse"]}] run tag @s add zx.ap_has
execute if items entity @s hotbar.6 *[custom_data~{zx:["apocalypse"]}] run tag @s add zx.ap_has
execute if items entity @s hotbar.7 *[custom_data~{zx:["apocalypse"]}] run tag @s add zx.ap_has
execute if items entity @s hotbar.8 *[custom_data~{zx:["apocalypse"]}] run tag @s add zx.ap_has
