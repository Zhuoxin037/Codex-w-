# ============================================================
# sweetdream:debug/deepsea_go —— 「深海的回响」手动推一帧(写入型)
# ------------------------------------------------------------
# 【用法】
#   /scoreboard players set @s zx.de_cast 11
#   /function sweetdream:debug/deepsea_go
#   -> 剑应当**定格在爆发帧**(护手全张 / 水晶爆亮)。
#      换个数字(0=蓄力起手, 31=回响末)再跑一次。
#
# 【它验证什么】把 anim/tick 里最关键的**第 ③ 层**单独拎出来跑:
#   "把 zx.de_cast 抄进 #decast -> item_modify 写进物品的 custom_model_data
#    -> 资源包 range_dispatch(index 1) 选到对应的 cast_NN 模型"。
#   如果跑完剑变了 = 这条路全通, 出问题的一定在"自动推帧"那一侧(状态机/节拍);
#   如果跑完剑毫无变化 = 问题在 item_modifier 或资源包的 items/sword.json 上。
#
# 【和 anim/tick 的区别】这里不碰 tag、不计数、不调 anim/fx,
#   所以跑它不会打乱正在播的动画 —— 但它写进去的帧号会被每秒的
#   anim/reset_hands 拉回待机(除非你正带着 zx.de_cast 标签在播动画)。
# ============================================================

scoreboard players operation #decast zx.meta = @s zx.de_cast
execute if items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["deepsea_echo"]}] run item modify entity @s weapon.mainhand sweetdream:deepsea/cast_frame
execute if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["deepsea_echo"]}] run item modify entity @s weapon.offhand sweetdream:deepsea/cast_frame
tellraw @s [{"text":"已按当前 zx.de_cast 推了一帧。","color":"yellow"},{"score":{"name":"#decast","objective":"zx.meta"},"color":"white"}]
tellraw @s [{"text":"剑有变化 = 这条链路通; 毫无变化 = item_modifier 或 items/sword.json 有问题","color":"gold","italic":true}]
