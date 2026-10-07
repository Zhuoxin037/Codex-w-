# ============================================================
# sweetdream:equipment/tool/wrath/second_one —— 愠怒: 每秒续「抗性提升Ⅰ」
# ------------------------------------------------------------
# 【谁调用它】wrath/second 里 `execute as @a at @s`
# 【执行者】玩家本人
# 【条件】副手拿着「愠怒」 且 血量低于 20%
# 【续多久】2 秒(每秒续) —— 条件消失后最多 2 秒自然消退, 表现上就是"常态"。
# ============================================================

# ⓪ 副手没拿「愠怒」-> 不管
execute unless items entity @s weapon.offhand *[minecraft:custom_data~{zx:["wrath"]}] run return 0

# ① 算血量差(< 0 = 低于 20%)
function sweetdream:equipment/tool/wrath/low_hp

# ② 低于 20% -> 续抗性提升Ⅰ(amplifier 0 = Ⅰ, 2 秒)
execute if score #wr_hp zx.meta matches ..-1 run effect give @s minecraft:resistance 2 0 true
