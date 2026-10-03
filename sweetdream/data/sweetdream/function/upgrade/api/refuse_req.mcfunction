# ============================================================
# sweetdream:upgrade/api/refuse_req —— "你缺的前置是哪一条"(宏 {req})
# ------------------------------------------------------------
# 【为什么要这一层】定义表里 req 存的是 id(mana_up_a 这种),
#   要显示中文名得先拿这个 id 去查它的 label —— 拼路径只能再走一次宏。
# ============================================================

$data modify storage zx:work up.msg set from storage zx:config updef."$(req)".label
tellraw @s [{"text":"✘ 需要先敲上「","color":"red"},{"nbt":"up.msg","storage":"zx:work","color":"yellow"},{"text":"」才能敲这条","color":"red"}]
