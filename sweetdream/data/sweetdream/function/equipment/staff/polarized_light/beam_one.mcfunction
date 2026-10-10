# ============================================================
# sweetdream:equipment/staff/polarized_light/beam_one —— 超限三道光: 铺其中一条
# ------------------------------------------------------------
# 【谁调用它】beam_ol 第 ③ 步(每轮一次; 执行者 = 施法玩家)
# 【做什么】① 从"还没画过"的锁定目标里挑最近的一个, 冻结成本条的目标
#   (zx.pl_cur = 画线终点 / beam_step 的"到达"判据; zx.pl_d = 已画过, 本刻不再选);
#   ② 步数计数归零(每条各自从头计 —— #pl_st 是全局假玩家, 三条共用);
#   ③ 从眼睛出发面朝它递归铺粒子(同基础版的 beam ④);
#   ④ 摘 zx.pl_cur(下一轮给别的目标让路; zx.pl_d 留到 beam_ol 末尾统一清)。
# 【宏参数】zx:work pb(施法者 UUID 四 int, beam_ol ② 备好)
# ============================================================

tag @e[tag=zx.pl_lock,tag=!zx.pl_d,limit=1] add zx.pl_cur
tag @e[tag=zx.pl_cur,limit=1] add zx.pl_d
scoreboard players set #pl_st zx.meta 0
# 本刻已画条数 +1(beam_ol ③ 的三轮分发靠它区分)
scoreboard players add #pl_n zx.meta 1
execute anchored eyes facing entity @e[tag=zx.pl_cur,limit=1] eyes run function sweetdream:equipment/staff/polarized_light/beam_step with storage zx:work pb
tag @e[tag=zx.pl_cur] remove zx.pl_cur
