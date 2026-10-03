# ============================================================
# sweetdream:equipment/sword/deepsea_echo/anim/tick —— 释放动画的每 tick 推帧
# ------------------------------------------------------------
# 【执行者】@a[tag=zx.de_cast]（由 sweetdream:core/tick 筛出来）
#
# 【帧号】zx.de_cast = 0..31 → cast_00..cast_31，共 32 tick = 1.6 秒。
#
# 【为什么结束条件是 33 而不是 32】踩过的坑（风行那边栽过一次）：
#   如果计数一到 32 就在同一 tick 里调 end、而 end 又把 floats[1] 写成 32（待机），
#   那么"推 cast_31"和"写 32"会落在**同一个 tick 内**。物品组件的同步是
#   "每 tick 只广播最终值"，于是 cast_31 这一帧根本到不了客户端 ——
#   动画会从 cast_30 直接跳到待机，最后一帧被吃掉。
#   所以让计数多走一格：32 那一 tick 什么都不推（画面停在 cast_31），
#   到 33 才收尾。客户端于是能完整看到 cast_31 整整一个 tick。
#
# 【#decast 是干什么的】item_modifier 里只能用 fixed 这种"名字写死"的
#   score provider（这是风行的 animation_frame 已经跑通的路子，可靠）。
#   要按**每个玩家各自的** zx.de_cast 推帧，就先把值抄进 #decast 再立刻 modify：
#   命令串行执行，抄一次用一次，轮到下一个玩家会重新抄，不会互相串味。
#   不用 context 选择器按实体取分数：那张写法在这套资源里没有先例，赌不起 ——
#   一旦 JSON 不合法，整个 item_modifier 加载失败，表现是"施法完全没动画"。
#
# 【为什么两只手都推】施法途中把剑换到副手，动画照样接着播。
# 【为什么必须每 tick 推、不能借别的节拍】释放动画要 20 fps 才不卡；
#   而每秒被动是 20 tick 一拍，借不得。
# ============================================================

scoreboard players operation #decast zx.meta = @s zx.de_cast
execute if score @s zx.de_cast matches ..31 if items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["deepsea_echo"]}] run item modify entity @s weapon.mainhand sweetdream:deepsea/cast_frame
execute if score @s zx.de_cast matches ..31 if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["deepsea_echo"]}] run item modify entity @s weapon.offhand sweetdream:deepsea/cast_frame

# 粒子与动画同一条帧号，所以"水花炸开"永远发生在护手张开的那几帧上。
# 放在 at @s 里是因为下面全是 ~ ~ ~ 的相对坐标。
execute if score @s zx.de_cast matches ..31 at @s run function sweetdream:equipment/sword/deepsea_echo/anim/fx

scoreboard players add @s zx.de_cast 1
execute if score @s zx.de_cast matches 33.. run function sweetdream:equipment/sword/deepsea_echo/anim/end
