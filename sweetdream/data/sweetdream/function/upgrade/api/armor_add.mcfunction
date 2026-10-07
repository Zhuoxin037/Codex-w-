# ============================================================
# sweetdream:upgrade/api/armor_add —— 护甲值加/减差值(硬化石)
# ------------------------------------------------------------
# 【入参】#diff = 差值(可正可负)   【执行者】玩家(zx:data self.uuid 已备好)
# 【只改原版属性】面板里没有"护甲值"这一项(和脊骨共生/apply_armor 同一套写法)。
# 【为什么无条件先摘再加】同 id 已存在时 modifier add 会失败; 摘一个不存在的 id
#   只是返回失败(函数继续往下跑), 无条件摘才能保证"账本是多少, 属性就是多少"。
# 【属性 id 本系统独有】sweetdream:upg_armor —— 和套装/脊骨共生的 id 分开, 各摘各的。
# 【上限】原版护甲属性最高 30, 超了会被自动夹住, 不是 bug。
# ============================================================

attribute @s minecraft:armor modifier remove sweetdream:upg_armor

scoreboard players operation @s zx.up_armor += #diff zx.meta
execute if score @s zx.up_armor matches 1.. run data modify storage zx:work x set value {v:0}
execute if score @s zx.up_armor matches 1.. store result storage zx:work x.v int 1 run scoreboard players get @s zx.up_armor
execute if score @s zx.up_armor matches 1.. run function sweetdream:upgrade/api/armor_attr with storage zx:work x
