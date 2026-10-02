# ============================================================
# sweetdream:debug/offhand_go —— 查盔甲架两个槽位的备份(宏 {uuid})
# ------------------------------------------------------------
# 【谁调用它】debug/offhand, 拿 UUID 用; 也可以自己调
# 【为什么必须宏】架子的标签是 test_stand_<uuid>, 而选择器里不能写动态值,
#   只能用宏把 UUID "烤"进命令里。
# 【架子在哪】固定住在主世界 (0.5,-60,0.5), 所以查它一律要切到主世界。
# ============================================================

# ⑤ 架子的主手槽
$execute in minecraft:overworld unless entity @e[tag=test_stand_$(uuid)] run tellraw @s [{"text":"⑤ 备份盔甲架: 不存在(等 2 秒自愈, 或重进一次)","color":"red"}]
$execute in minecraft:overworld if items entity @e[tag=test_stand_$(uuid),limit=1] weapon.mainhand * run tellraw @s [{"text":"⑤ 架子 主手槽: 有备份 ✓","color":"green"}]
$execute in minecraft:overworld unless items entity @e[tag=test_stand_$(uuid),limit=1] weapon.mainhand * run tellraw @s [{"text":"⑤ 架子 主手槽: 空","color":"gray"}]
$execute in minecraft:overworld if items entity @e[tag=test_stand_$(uuid),limit=1] weapon.offhand * run tellraw @s [{"text":"⑥ 架子 副手槽: 有备份 ✓","color":"green"}]
$execute in minecraft:overworld unless items entity @e[tag=test_stand_$(uuid),limit=1] weapon.offhand * run tellraw @s [{"text":"⑥ 架子 副手槽: 空","color":"gray"}]

tellraw @s [{"text":"   副手拿着武器但⑥是空 -> 备份没做成, 用了就会消失","color":"dark_gray"}]
