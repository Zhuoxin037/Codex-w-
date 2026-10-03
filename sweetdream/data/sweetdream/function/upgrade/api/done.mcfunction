# ============================================================
# sweetdream:upgrade/api/done —— 敲成功了, 告诉玩家敲上了什么(宏 {id})
# ------------------------------------------------------------
# 【为什么要单独一层】提示里要显示这块石头的中文名和效果说明,
#   那两样都在定义表里, 拼 NBT 路径只能走宏。
# 【为什么先 set 再打印】tellraw 的 nbt 组件是"打印时去读",
#   不先把值搬进临时节点就读不到(NBT 路径不支持带宏变量的参数化)。
# ============================================================

$data modify storage zx:work up.msg set from storage zx:config updef."$(id)".label
$data modify storage zx:work up.note set from storage zx:config updef."$(id)".note
tellraw @s [{"text":"✔ 已敲上 ","color":"green"},{"nbt":"up.msg","storage":"zx:work","color":"aqua"},{"text":"（","color":"gray"},{"nbt":"up.note","storage":"zx:work","color":"gray"},{"text":"）","color":"gray"}]
playsound minecraft:block.smithing_table.use player @s ~ ~ ~ 0.8 1.2
