# ============================================================
# sweetdream:equipment/axe/ballad/ol_note_tick —— 「音符」每刻推进
# ------------------------------------------------------------
# 【谁调用它】core/tick(三维度各一遍)   【执行者】音符 marker   【位置】它的位置
# 【做什么】倒计时 20 刻(1 秒) -> 到 0 时读 NBT 交给 ol_note_go 结算并自毁
# 【★ 只有最后那一拍读 NBT ★】中途 19 刻只动计分项 zx.nt_t —— 每刻读 marker NBT
#   会让区块变脏(卡顿条目 1: 每刻写/读实体 NBT)。
# 【★ 结算就是自毁 ★】ol_note_go 末尾 kill @s; 这里到 0 之后不会再有第二拍。
# ============================================================

# ① 倒计时(20 -> 0)
execute if score @s zx.nt_t matches 1.. run scoreboard players remove @s zx.nt_t 1

# ② 飞行前的音符光点(轻)
execute if score @s zx.nt_t matches 1.. run particle minecraft:note ~ ~0.4 ~ 0.15 0.15 0.15 0.01 1 normal

# ③ 到点: 把 NBT 拷进 storage(宏参数只能取自 storage) -> 结算
data remove storage zx:work ntgo
execute if score @s zx.nt_t matches 0 run data modify storage zx:work ntgo set from entity @s data.zx
execute if score @s zx.nt_t matches 0 run function sweetdream:equipment/axe/ballad/ol_note_go with storage zx:work ntgo
