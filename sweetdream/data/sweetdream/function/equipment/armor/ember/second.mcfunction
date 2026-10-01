# ============================================================
# sweetdream:equipment/armor/ember/second —— 余烬·每秒入口
# ------------------------------------------------------------
# 【谁调用它】#manacore:event/second
# 【为什么改成逐玩家】事件标签是服务器身份执行的, 层里没有 @s;
#   旧版直接写 `execute unless items entity @s ...` 在服务器身份下
#   找不到玩家, 后面的 @e[distance=..9] 也会以世界出生点为中心算。
#   所以这里先 `as @a at @s`, 后面的"自身 9 格内"才是玩家身边。
# 【边沿检测】zx.em_burn = "上一秒还在燃烧"的目标标记。
#   本秒先处理旧标记, 再把当前还在燃烧的目标重新打上标记。
#   不扫描/不清除远处目标的标记: 多人同时穿余烬时, 远处标记可能
#   还需要另一个玩家处理, 全局清掉会漏触发。
# ============================================================

# 【为什么对全部玩家跑】魔力上限 +240 是"穿上加, 脱下减"的差值账本:
#   如果只筛穿余烬的人, 脱下那一秒就没人执行 second_one, 240 永远减不回去。
#   所以先让所有人进来, 由 second_one 自己判断"这件装备在不在身上"。
# 【备份公共输入口】second_one 会通过 api/stats/add 改魔力上限, 会写
#   manacore:in arg; 用 lib/in_bak 包住整段, 不冲掉聊天栏手填的参数。
function sweetdream:lib/in_bak

execute as @a at @s run function sweetdream:equipment/armor/ember/second_one

function sweetdream:lib/in_restore
