# ============================================================
# sweetdream:equipment/axe/thunderclap/join_scan —— 按 UUID 四整数找"我的术阵"
# ------------------------------------------------------------
# 【宏参数】zx:work jc {u0,u1,u2,u3}
# 【出参】找到 -> @s zx.tc_on = 1   【执行者】玩家
# ★ @e 不带位置参数 = 搜**全部维度**(术阵可能留在别的维度) —— 这里正是要跨维度
#   (RULES 坑 55 的豁免情形)。marker 上存的就是 data.zx.u 四个整数。
#   zx.tc_mine 是本函数内部的临时中转标签, 用完即删。
# ============================================================
tag @e[tag=zx.tc_field] remove zx.tc_mine
$tag @e[tag=zx.tc_field,nbt={data:{zx:{u:[I;$(u0),$(u1),$(u2),$(u3)]}}}] add zx.tc_mine
execute if entity @e[tag=zx.tc_mine] run scoreboard players set @s zx.tc_on 1
tag @e[tag=zx.tc_mine] remove zx.tc_mine
