# ============================================================
# naturewind/cast_end —— 释放动画收尾
# ------------------------------------------------------------
# 【执行者】刚播完释放动画的人（由 cast_tick 在 cast_t 到 26 时调进来）
# 【做什么】把法杖的 floats[1] 写成 26 → 模型立刻回到待机那一套；
#   然后摘掉 tag 和计分项，让这个人从 cast_tick 的筛选里退出。
# 【这是第一道收尾】第二道在 step.mcfunction 里：那里对
#   所有「没在施法」的持杖者每 3 tick 写一次 cast_idle。两道叠在一起
#   是为了兜住两种漏网情况 ——
#     · 施法途中把法杖丢在地上 → 这里的 `if items` 不成立，推不进去；
#     · 施法途中把法杖换到别的栏位再换回来 → 物品上留着中途的帧号。
#   靠 step 那一层，最长 3 tick 之内就会自己归位。
# ============================================================

execute if items entity @s weapon.mainhand minecraft:recovery_compass[minecraft:item_model="naturewind:staff"] run item modify entity @s weapon.mainhand naturewind:cast_idle
execute if items entity @s weapon.offhand minecraft:recovery_compass[minecraft:item_model="naturewind:staff"] run item modify entity @s weapon.offhand naturewind:cast_idle
scoreboard players reset @s nw.cast_t
tag @s remove nw.casting
