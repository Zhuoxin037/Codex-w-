# ============================================================
# sweetdream:equipment/sword/deepsea_echo/anim/reset_hands —— 残留帧号的兜底归位
# ------------------------------------------------------------
# 【谁调用它】deepsea_echo/second（每秒），执行者是每个玩家
# 【干什么】没在播释放动画的人，两只手上的深海剑一律把 floats[1] 写成 32（待机）。
# 【为什么需要】施法那 1.6 秒里如果把剑**换到别的快捷栏再换回来**，或者丢在地上，
#   anim/tick 的 `if items entity @s weapon.mainhand` 就推不进去，物品上会残留
#   一个中途帧号（比如 11 = 护手全张 + 水晶爆亮）。等施法结束、tag 摘掉之后，
#   再也没有任何东西会去修正它 —— range_dispatch(index 1) 会一直命中 cast_11，
#   表现成"这把剑的待机外观永久变成爆发瞬间的样子"。
# 【为什么先判 tag】正在播动画的人不能被归位，否则动画会每秒钟被掐一次。
# ============================================================

execute unless entity @s[tag=zx.de_cast] if items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["deepsea_echo"]}] run item modify entity @s weapon.mainhand sweetdream:deepsea/cast_idle
execute unless entity @s[tag=zx.de_cast] if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["deepsea_echo"]}] run item modify entity @s weapon.offhand sweetdream:deepsea/cast_idle
