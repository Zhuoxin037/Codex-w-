# ============================================================
# sweetdream:upgrade/api/fit_req —— 前置升级在不在(宏 {req})
# ------------------------------------------------------------
# 【出参】#up_reqbad = 1 表示"缺前置"; 0 表示通过。
# 【为什么单独一层】req 是定义表里的一个**字符串**, 要拼进物品谓词只能再走一次宏;
#   而且"空字符串"表示没有前置, 直接放行。
# 【为什么要先 set 0】#up_reqbad 是跨调用复用的临时量 ——
#   不先归零的话, 上一次留下的 1 会让这次平白无故失败。
# ============================================================

scoreboard players set #up_reqbad zx.meta 0
# 空前置 = 不需要校验
execute if data storage zx:work up{req:""} run return 0
$execute unless items entity @s weapon.offhand *[minecraft:custom_data~{up:["$(req)"]}] run scoreboard players set #up_reqbad zx.meta 1
