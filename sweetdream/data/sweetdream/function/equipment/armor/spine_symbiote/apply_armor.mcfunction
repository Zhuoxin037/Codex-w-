# ============================================================
# sweetdream:equipment/armor/spine_symbiote/apply_armor —— 护甲值加/减差值
# ------------------------------------------------------------
# 【入参】#diff = 差值(可正可负)   【执行者】玩家
# 【只改原版属性】面板里没有"护甲值"这一项, 所以只有 minecraft:armor 要动。
# 【为什么无条件先摘再加】同 id 已存在时 add 会失败; 摘一个不存在的 id 只是
#   返回失败(函数会继续), 无条件摘才能保证账本与属性不会失同步。
# 【上限】原版护甲属性最高 30, 超了会自动夹住, 不是 bug。
# ============================================================

attribute @s minecraft:armor modifier remove sweetdream:eqp_ss_armor

scoreboard players operation @s zx.ss_armor += #diff zx.meta
execute if score @s zx.ss_armor matches 1.. run data modify storage zx:work x set value {v:0}
execute if score @s zx.ss_armor matches 1.. store result storage zx:work x.v int 1 run scoreboard players get @s zx.ss_armor
execute if score @s zx.ss_armor matches 1.. run function sweetdream:equipment/armor/spine_symbiote/armor_add with storage zx:work x
