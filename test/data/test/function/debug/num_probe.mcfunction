# ============================================================
# test:debug/num_probe —— 检查宏渲染到底长什么样
# ------------------------------------------------------------
# 【用法】/function test:debug/num_probe
# 【看什么】每一行会显示"宏渲染出来的原始字符串"和"切完后缀的最终结果"。
#   正常应该看到 原始 = 37.5d / 切完 = 37.5
#   如果原始就不带 d, 那切完也还是 37.5 —— 说明本包的自适应判断
#   在你这台环境上按另一个分支走, 同样是正确的, 不用改代码。
# 【什么时候需要跑它】一旦 /damage 报"应为双精度浮点型"之类的错, 先跑这个,
#   就能判断是数字字符串的锅还是命令本身的锅。
# ============================================================

data modify storage test:work a.num set value 37.5
function test:lib/num/plain
data modify storage test:work probe.raw1 set from storage test:work a.raw
data modify storage test:work probe.str1 set from storage test:work a.num_str

data modify storage test:work a.num set value 20.0
function test:lib/num/plain
data modify storage test:work probe.raw2 set from storage test:work a.raw
data modify storage test:work probe.str2 set from storage test:work a.num_str

data modify storage test:work a.num set value -3.25
function test:lib/num/plain
data modify storage test:work probe.raw3 set from storage test:work a.raw
data modify storage test:work probe.str3 set from storage test:work a.num_str

tellraw @s [{"text":"[num_probe] 宏渲染 vs 最终结果","color":"gold"}]
tellraw @s [{"text":"37.5  -> raw: ","color":"gray"},{"nbt":"probe.raw1","storage":"test:work"},{"text":"  -> num_str: ","color":"gray"},{"nbt":"probe.str1","storage":"test:work"}]
tellraw @s [{"text":"20.0  -> raw: ","color":"gray"},{"nbt":"probe.raw2","storage":"test:work"},{"text":"  -> num_str: ","color":"gray"},{"nbt":"probe.str2","storage":"test:work"}]
tellraw @s [{"text":"-3.25 -> raw: ","color":"gray"},{"nbt":"probe.raw3","storage":"test:work"},{"text":"  -> num_str: ","color":"gray"},{"nbt":"probe.str3","storage":"test:work"}]
