# ============================================================
# sweetdream:debug/damage —— 伤害链路自检(只读)
# ------------------------------------------------------------
# 【用法】打完一下之后**立刻** /function sweetdream:debug/damage
# 【看什么】
#   · 最近一次"横刀落点 / 风声回响"的范围选择器选中了几只 ——
#     0 就说明选择器一只都没选到(最典型的原因是执行位置不对: 少了 at @s)
#   · /damage 被调用了几次、最近一次用的数字与伤害类型
#   · manacore 算出来的伤害、接口的出参
# 【为什么需要它】命令在函数里失败是**静默**的: 不报错、不写日志, 只表现为
#   "看起来放出来了, 但一点伤害都没有"。所以只能靠把中间量记下来再看。
# 【它是只读的】不会改任何游戏数据。
# ============================================================

tellraw @s [{"text":"===== 伤害链路自检 =====","color":"gold","bold":true}]

tellraw @s [{"text":"最近范围命中数   ","color":"gray"},{"score":{"name":"#dbg_sel","objective":"zx.meta"},"color":"white"},{"text":"   (0 = 选择器没选中任何生物)","color":"dark_gray"}]
tellraw @s [{"text":"/damage 调用次数 ","color":"gray"},{"score":{"name":"#dbg_calls","objective":"zx.meta"},"color":"white"}]

execute if data storage zx:data last.num run tellraw @s [{"text":"最近一次伤害数字 ","color":"gray"},{"nbt":"last.num","storage":"zx:data","color":"white"},{"text":"   类型 ","color":"dark_gray"},{"nbt":"last.type","storage":"zx:data","color":"white"}]
execute unless data storage zx:data last.num run tellraw @s [{"text":"还没有任何 /damage 被调用过","color":"red"}]

# 【★ 命令成败 ★】0 = 那条 /damage **根本没成功**。最常见的原因是伤害类型
#   没注册进世界(damage_type 是注册表, /reload 补不上) —— 详见
#   /function sweetdream:debug/true_damage
execute if data storage zx:data last.num run tellraw @s [{"text":"那次 /damage 成功? ","color":"gray"},{"score":{"name":"#dbg_dmg","objective":"zx.meta"},"color":"white"},{"text":"   (0 = 命令失败, 去查伤害类型)","color":"dark_gray"}]

execute if data storage manacore:out r.damage run tellraw @s [{"text":"manacore 算出的伤害 ","color":"gray"},{"nbt":"r.damage","storage":"manacore:out","color":"aqua"}]
tellraw @s [{"text":"接口出参 applied ","color":"gray"},{"nbt":"r.applied","storage":"zx:out","color":"yellow"},{"text":"   damage ","color":"dark_gray"},{"nbt":"r.damage","storage":"zx:out","color":"yellow"}]
