# ============================================================
# sweetdream:equipment/armor/condensed_shell/freeze_new —— 冻住"首次进入"的那一只
# ------------------------------------------------------------
# 【谁调用它】condensed_shell/field_tick ②, 执行者 = 那只生物, #cs_iid = 本次领域实例号
# 【干什么】① 把领域实例号记到它自己身上(这个领域再 tick 就不会重复冻它了)
#   ② 冻 1 秒。
# 【为什么 1 秒 = 20 刻】文案"冰冻 1 秒"; lib/freeze 的单位是**刻**。
# 【为什么走 lib/freeze 而不是自己写】包内统一口径: 写 TicksFrozen = 140(原版结霜外观)
#   + 移动速度乘区 -100%(真的走不动, 但还能转身/攻击); 每秒由 lib/freeze_hold 续期、
#   到点由它当场解冻、unfreeze_sweep 再兜底。实现细节见 lib/freeze 文件头。
# ============================================================

# ① 记下"我是被哪个领域冻的"(下次 field_tick 一比相等就跳过)
scoreboard players operation @s zx.cs_fid = #cs_iid zx.meta

# ② 冻 1 秒(20 刻)
data modify storage zx:work fz set value {target:"@s",ticks:20}
function sweetdream:lib/freeze with storage zx:work fz
