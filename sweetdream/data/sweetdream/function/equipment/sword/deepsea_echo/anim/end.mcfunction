# ============================================================
# sweetdream:equipment/sword/deepsea_echo/anim/end —— 释放动画收尾
# ------------------------------------------------------------
# 【执行者】刚播完释放动画的人（由 anim/tick 在 zx.de_cast 到 33 时调进来）
# 【做什么】把剑的 floats[1] 写成 32 → range_dispatch(index 1) 立刻命中
#   threshold 32 那一条，模型回到原来的待机形态；
#   然后摘掉 tag 和计分项，让这个人从 core/tick 的筛选里退出。
#
# 【这是第一道收尾】第二道在 deepsea_echo/second 里（每秒一次）：
#   对所有「没在施法」的持剑者写一次 cast_idle。两道叠在一起是兜住两种漏网情况 ——
#     · 施法途中把剑丢在地上 → 这里的 `if items` 不成立，推不进去；
#     · 施法途中把剑换到别的栏位再换回来 → 物品上留着中途的帧号。
#   靠 second 那一层，最长 1 秒之内就会自己归位。
#   （风行那边是每 3 tick 扫一遍，深海没有那个节拍，借每秒被动即可 ——
#    残留一帧半秒的"护手半张"没有任何实质影响。）
# ============================================================

execute if items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["deepsea_echo"]}] run item modify entity @s weapon.mainhand sweetdream:deepsea/cast_idle
execute if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["deepsea_echo"]}] run item modify entity @s weapon.offhand sweetdream:deepsea/cast_idle
scoreboard players reset @s zx.de_cast
tag @s remove zx.de_cast
