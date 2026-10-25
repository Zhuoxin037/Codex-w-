# ============================================================
# sweetdream:equipment/sword/gousi/ol_buff_land —— 超限·钩丝: 拉到一个的加成(执行者 = 施法者)
# ------------------------------------------------------------
# 【文案】"每拉到一个都会使自身下三次技能伤害 +10%（独立乘区）"
# 【叠法(已定口径)】"下三次"是**共享**的: 三层不各给三次, 拉满三个 = 下三次技能各 +30%。
#   · zx.gs3p = 每层 +10 的百分点(0/10/20/30, 封顶 30)
#   · zx.gs3n = 还剩下的次数(拉到即刷成 3)
# 【★ 为什么次数不累加 ★】"共享"就是累加的反面。拉第二只时若写 +3 次, 拉满
#   三个会变成"九次技能各 +30%" —— 那是文案的九倍。
# 【真正乘在哪】equipment/sword/gousi/hook_calc(挂在 #manacore:event/damage_calc,
#   声明 # @calc: indep = 独立乘区, 排在 lib/dmg_add_apply 之后)。
# ============================================================

scoreboard players add @s zx.gs3p 10
execute if score @s zx.gs3p matches 31.. run scoreboard players set @s zx.gs3p 30
scoreboard players set @s zx.gs3n 3
