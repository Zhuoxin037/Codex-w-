# ============================================================
# naturewind/cast_tick —— 释放动画的每 tick 推帧
# ------------------------------------------------------------
# 【执行者】@a[tag=nw.casting]
#
# 【帧号】nw.cast_t = 0..25 → cast_00..cast_25，共 26 tick = 1.3 秒。
#
# 【为什么结束条件是 27 而不是 26】这是个踩过的坑：如果 cast_t 一到 26 就
#   在同一 tick 里调 cast_end，而 cast_end 又要把 floats[1] 写成 26（待机），
#   那么"推 cast_25"和"写 26"会落在**同一个 tick 内**。物品组件的同步是
#   "每 tick 只广播最终值"，于是 cast_25 这一帧根本到不了客户端 ——
#   动画会从 cast_24 直接跳到待机，最后一帧被吃掉。
#   所以让 cast_t 多走一格：26 那一 tick 什么都不推（画面停在 cast_25），
#   到 27 才收尾。客户端于是能完整看到 cast_25 整整一个 tick。
#
# 【#castnow 是干什么的】item_modifier 里只能用 fixed 这种"名字写死"的
#   score provider（这是 animation_frame 已经在跑的路子，可靠）。
#   要按**每个玩家各自的** nw.cast_t 推帧，就先把值抄进 #castnow 再立刻 modify：
#   命令是串行执行的，抄一次用一次，轮到下一个玩家会重新抄，不会互相串味。
#   之所以不用 context 选择器按实体取分数：那张写法在这套资源里没有先例，
#   赌不起 —— 一旦 JSON 不合法，整个 item_modifier 加载失败，
#   表现是"施法完全没动画"，排查起来还得再进一次游戏。
#
# 【为什么两只手都推】施法途中把法杖换到副手，动画照样接着播。
# 【为什么必须每 tick 推、不能借待机的节拍】待机那边是 3 tick 一个相位
#   （为省性能），释放动画要 20 fps 才不卡。两条节拍必须分开走。
# ============================================================

scoreboard players operation #castnow nw.anim = @s nw.cast_t
execute if score @s nw.cast_t matches ..25 if items entity @s weapon.mainhand minecraft:recovery_compass[minecraft:item_model="naturewind:staff"] run item modify entity @s weapon.mainhand naturewind:cast_frame
execute if score @s nw.cast_t matches ..25 if items entity @s weapon.offhand minecraft:recovery_compass[minecraft:item_model="naturewind:staff"] run item modify entity @s weapon.offhand naturewind:cast_frame
scoreboard players add @s nw.cast_t 1
execute if score @s nw.cast_t matches 27.. run function naturewind:cast_end
