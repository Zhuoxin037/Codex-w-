# ------------------------------------------------------------
# internal/mana/mod_prep —— 把选中的槽位号交给写入函数
# 【做什么】#free -> work a.i, 然后调用 mod_write。
# 【为什么要中转】宏占位符只能来自复合标签, 而 #free 是计分板, 必须先落到
#         存储里, 才能作为占位符 i 参与路径拼接(players "<uuid>".regen_mods[i])。
# ------------------------------------------------------------
execute store result storage manacore:work a.i int 1 run scoreboard players get #free manacore.math
function manacore:internal/mana/mod_write with storage manacore:work a
