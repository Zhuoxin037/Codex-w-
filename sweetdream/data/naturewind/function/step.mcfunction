scoreboard players set #clock nw.anim 0
scoreboard players add #frame nw.anim 1
execute if score #frame nw.anim matches 16.. run scoreboard players set #frame nw.anim 0
execute as @a unless entity @s[tag=test_pending_return] if items entity @s weapon.mainhand minecraft:recovery_compass[minecraft:item_model="naturewind:staff"] run item modify entity @s weapon.mainhand naturewind:animation_frame
execute as @a unless entity @s[tag=test_pending_return] if items entity @s weapon.offhand minecraft:recovery_compass[minecraft:item_model="naturewind:staff"] run item modify entity @s weapon.offhand naturewind:animation_frame

# 【释放动画的兜底】没在施法的人，法杖上的 floats[1] 一律写成 26（= 待机）。
# 为什么必须有这一层：施法那 1.3 秒里玩家如果把法杖**换到别的快捷栏再换回来**，
# 或者干脆丢在地上，cast_tick 的 `if items entity @s weapon.mainhand` 就推不进去，
# 物品上会残留一个中途帧号（比如 15 = 枝冠半张）。等施法结束、tag 摘掉之后，
# 再也没有任何东西会去修正它 —— range_dispatch(index 1) 会一直命中 cast_15，
# 表现成"这把杖的待机动画永久失效、枝冠一直是半张的"。
# 这里每 3 tick 扫一遍兜住它，最长 3 tick（150 ms）之内归位。
# 正在施法的人被 unless tag=nw.casting 排除，不会打断正在播的动画。
execute as @a unless entity @s[tag=nw.casting] if items entity @s weapon.mainhand minecraft:recovery_compass[minecraft:item_model="naturewind:staff"] run item modify entity @s weapon.mainhand naturewind:cast_idle
execute as @a unless entity @s[tag=nw.casting] if items entity @s weapon.offhand minecraft:recovery_compass[minecraft:item_model="naturewind:staff"] run item modify entity @s weapon.offhand naturewind:cast_idle
