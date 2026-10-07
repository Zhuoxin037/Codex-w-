# ============================================================
# sweetdream:equipment/axe/thunderclap/bolt —— 威霆: 判断"这一下要不要落雷"
# ------------------------------------------------------------
# 【谁调用它】thunderclap/hit(①, 已有术阵时)
# 【执行者】施法者(玩家)
# 【做什么】① 找到自己的术阵(场上同刻最多一个 —— 用"离自己最近的 zx.tc_field"取)
#   ② 被击者(zx.victim)必须在术阵半径 6 格内, 否则什么都不做
#   ③ 交给术阵自己结算(bolt_go 需要读 marker 上的 X / uuid)
# 【★ 为什么用"最近的术阵" ★】术阵生成在被击者处、且"结束前不能再开", 所以同刻这名玩家
#   名下只会有一个; 取离自己最近的那个即可。多人同时用时各取各自附近的那一个。
# ============================================================

tag @e[distance=0..,tag=zx.tc_f] remove zx.tc_f
execute at @s as @e[type=minecraft:marker,tag=zx.tc_field,distance=0..16,sort=nearest,limit=1] run tag @s add zx.tc_f
execute unless entity @e[tag=zx.tc_f,distance=0..,limit=1] run return 0

# 被击者必须在术阵半径 6 格内
execute at @e[tag=zx.tc_f,distance=0..,limit=1] unless entity @e[type=!#sweetdream:no_damage,tag=zx.victim,distance=..6] run tag @e[distance=0..,tag=zx.tc_f] remove zx.tc_f
execute unless entity @e[tag=zx.tc_f,distance=0..,limit=1] run return 0

# 交给术阵结算
execute as @e[tag=zx.tc_f,distance=0..,limit=1] at @s run function sweetdream:equipment/axe/thunderclap/bolt_go
tag @e[distance=0..,tag=zx.tc_f] remove zx.tc_f
