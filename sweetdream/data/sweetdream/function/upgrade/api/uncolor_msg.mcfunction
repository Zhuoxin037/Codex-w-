# ============================================================
# sweetdream:upgrade/api/uncolor_msg —— 消除成功的提示(宏 {id})
# ------------------------------------------------------------
# 【宏参数】zx:work uc {id} = 被消那条的石头 id
# 【为什么转一层】提示里要显示被消石头的中文名(定义表路径带宏)。
# 【文案为什么提"该系列"】返还的是**整条链**(消 Ω 还 α+β+Ω),
#   照 uncolor_give 的口径说"该系列的升级石已全部还给你"。
# ============================================================

$data modify storage zx:work up.msg set from storage zx:config updef."$(id)".label
tellraw @s [{"text":"✔ 已消除 ","color":"green"},{"nbt":"up.msg","storage":"zx:work","color":"aqua"},{"text":"，该系列的升级石已全部还给你","color":"gray"}]
playsound minecraft:block.grindstone.use player @s ~ ~ ~ 0.8 0.8
