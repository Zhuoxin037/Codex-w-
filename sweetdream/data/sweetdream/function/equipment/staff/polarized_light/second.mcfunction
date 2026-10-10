# ============================================================
# sweetdream:equipment/staff/polarized_light/second —— 偏振光的每秒入口
# ------------------------------------------------------------
# 【谁调用它】挂在 #manacore:event/second 上(前置包每秒抛一次, 全局身份)
# 【★ 必须写 at @s ★】光线锁 10 格内最近, 全要相对玩家算(见 charge/second)。
# 【★ 基础版专属 ★】筛 zx.pl_ol=0: 超限版是"每 0.5 秒"节奏, 由 core/tick 的
#   half 驱动(见 half.mcfunction); 不分流的话超限版会被这里再打一遍 = 双倍伤害。
#   ★ zx.pl_ol 由 skill ①' 每次施法都写(0/1), 所以 "="0" 不会漏掉任何人。
# ============================================================

execute as @a[scores={zx.pl_t=1..,zx.pl_ol=0}] at @s run function sweetdream:equipment/staff/polarized_light/tick
