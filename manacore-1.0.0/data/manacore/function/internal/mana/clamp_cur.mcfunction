# ------------------------------------------------------------
# internal/mana/clamp_cur —— 把当前魔力压回上限
# 【宏参数】manacore:work.a {uuid}
# 【说明】被 remove_max_body 调用; 此时 #max 已经算好, 直接写入即可。
# ------------------------------------------------------------
$execute store result storage manacore:players "$(uuid)".stats.current_mana double 0.001 run scoreboard players get #max manacore.math
