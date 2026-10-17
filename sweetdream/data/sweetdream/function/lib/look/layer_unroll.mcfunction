# ============================================================
# sweetdream:lib/look/layer_unroll —— 把「层数机制」表逐行喂给渲染器
# ------------------------------------------------------------
# 【这个文件是生成的】改动请看 lib/reg/build.mcfunction 的 layer 表, 然后跑
#   python .workbuddy/gen_reg_unroll.py
# 【谁调它】equipment/tool/look/render_go(观测镜刷新时, 拼第二行)
# 【为什么要写这么长】Minecraft 没有循环 —— 表里第 N 行就得有第 N 条命令。
#   槽数 = build 里登记的 cap(layer); 表比槽长的话多出来的行不会显示。
# 【执行者】玩家本人
# ============================================================

# ---------- layer 表: 只显示在身 / 在手上的层数机制 ----------
execute if data storage zx:reg layer[0] run function sweetdream:lib/look/layer_row with storage zx:reg layer[0]
execute if data storage zx:reg layer[1] run function sweetdream:lib/look/layer_row with storage zx:reg layer[1]
execute if data storage zx:reg layer[2] run function sweetdream:lib/look/layer_row with storage zx:reg layer[2]
execute if data storage zx:reg layer[3] run function sweetdream:lib/look/layer_row with storage zx:reg layer[3]
execute if data storage zx:reg layer[4] run function sweetdream:lib/look/layer_row with storage zx:reg layer[4]
execute if data storage zx:reg layer[5] run function sweetdream:lib/look/layer_row with storage zx:reg layer[5]
execute if data storage zx:reg layer[6] run function sweetdream:lib/look/layer_row with storage zx:reg layer[6]
execute if data storage zx:reg layer[7] run function sweetdream:lib/look/layer_row with storage zx:reg layer[7]
execute if data storage zx:reg layer[8] run function sweetdream:lib/look/layer_row with storage zx:reg layer[8]
execute if data storage zx:reg layer[9] run function sweetdream:lib/look/layer_row with storage zx:reg layer[9]
execute if data storage zx:reg layer[10] run function sweetdream:lib/look/layer_row with storage zx:reg layer[10]
execute if data storage zx:reg layer[11] run function sweetdream:lib/look/layer_row with storage zx:reg layer[11]
execute if data storage zx:reg layer[12] run function sweetdream:lib/look/layer_row with storage zx:reg layer[12]
execute if data storage zx:reg layer[13] run function sweetdream:lib/look/layer_row with storage zx:reg layer[13]
execute if data storage zx:reg layer[14] run function sweetdream:lib/look/layer_row with storage zx:reg layer[14]
execute if data storage zx:reg layer[15] run function sweetdream:lib/look/layer_row with storage zx:reg layer[15]
execute if data storage zx:reg layer[16] run function sweetdream:lib/look/layer_row with storage zx:reg layer[16]
execute if data storage zx:reg layer[17] run function sweetdream:lib/look/layer_row with storage zx:reg layer[17]
execute if data storage zx:reg layer[18] run function sweetdream:lib/look/layer_row with storage zx:reg layer[18]
execute if data storage zx:reg layer[19] run function sweetdream:lib/look/layer_row with storage zx:reg layer[19]
execute if data storage zx:reg layer[20] run function sweetdream:lib/look/layer_row with storage zx:reg layer[20]
execute if data storage zx:reg layer[21] run function sweetdream:lib/look/layer_row with storage zx:reg layer[21]
execute if data storage zx:reg layer[22] run function sweetdream:lib/look/layer_row with storage zx:reg layer[22]
