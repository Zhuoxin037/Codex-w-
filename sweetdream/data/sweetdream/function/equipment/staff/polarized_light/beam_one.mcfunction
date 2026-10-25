# ============================================================
# sweetdream:equipment/staff/polarized_light/beam_one —— 超限三道光: 铺其中一条
# ------------------------------------------------------------
# 【谁调用它】beam_ol 第 ③ 步(每轮一次; 执行者 = 施法玩家)
# 【做什么】① 从"还没画过"的锁定目标里挑最近的一个, 冻结成本条的目标
#   (zx.pl_cur = 画线终点 / beam_step 的"到达"判据; zx.pl_d = 已画过, 本刻不再选);
#   ② 步数计数归零(每条各自从头计 —— #pl_st 是全局假玩家, 三条共用);
#   ③ 从眼睛出发面朝它递归铺粒子(同基础版的 beam ④);
#   ④ 摘 zx.pl_cur(下一轮给别的目标让路; zx.pl_d 留到 beam_ol 末尾统一清)。
# 【★ 2026-10-20 第二次卡顿修复】递归调用去掉 `with storage zx:work pb` ——
#   beam_step 已不含宏参数(水晶归属判定挪到 cry_scan, 每束光一次)。
#   这是超限三道光的**主要**开销来源: 原来每步一次宏调用 × 3 道 ≈ 90 次/刻。
# ============================================================

scoreboard players set @e[tag=zx.pl_lock,scores={zx.pl_d=0},limit=1] zx.pl_cur 1
scoreboard players set @e[tag=zx.pl_lock,scores={zx.pl_cur=1}] zx.pl_d 1
scoreboard players set #pl_st zx.meta 0
# 本刻已画条数 +1(beam_ol ③ 的三轮分发靠它区分)
scoreboard players add #pl_n zx.meta 1
execute anchored eyes facing entity @e[tag=zx.pl_lock,scores={zx.pl_cur=1},limit=1] eyes run function sweetdream:equipment/staff/polarized_light/beam_step
scoreboard players set @e[tag=zx.pl_lock,scores={zx.pl_cur=1}] zx.pl_cur 0
