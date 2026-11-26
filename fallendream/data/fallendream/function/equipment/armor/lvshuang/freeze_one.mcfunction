# ============================================================
# fallendream:equipment/armor/lvshuang/freeze_one —— 这只生物这一秒该被冻吗（执行者 = 生物）
# ------------------------------------------------------------
# 【谁调用它】ol_freeze ③（对霜片 1.2 格内的每只生物）
# 【三条拒绝】
#   ① 已经在冷冻里（标签 zx.freeze，不论是谁冻的）—— 不抢别人的计时
#   ② 距上次被霜冻不足 #lsh_need 刻 —— "踩到"只算一次，不是"踩在上面"
#   ③ （无）
# 【★ 判据写法 ★】#lsh_gap < #lsh_need 是**两个计分项比大小**，不能写 matches
#   （matches 只吃字面量）。取不到 @s zx.lsh_fz 时 `-=` 会静默失败、#lsh_gap 保持
#   = #now（很大数）⇒ 自然放行，正是"从没被冻过"该有的行为。
# ============================================================

# 【★ 玩家不冻（技术+平衡双理由）★】lib/freeze 靠 `data modify entity @s TicksFrozen`
#   写原版冻结计数器，而**玩家 NBT 只读**（坑 162）—— 那一行对玩家必然失败并刷日志。
#   另外"移速 -100%"落在玩家身上就是 PvP 锁人。所以冷冻只对非玩家生物生效；
#   玩家踩到霜仍然吃缓慢Ⅱ（frost_tick ①，那条跟这里无关）。
execute if entity @s[type=minecraft:player] run return 0

execute if entity @s[tag=zx.freeze] run return 0

scoreboard players operation #lsh_gap zx.meta = #now manacore.meta
scoreboard players operation #lsh_gap zx.meta -= @s zx.lsh_fz
execute if score #lsh_gap zx.meta < #lsh_need zx.meta run return 0

tag @s add zx.lsh_fzr
scoreboard players operation @s zx.lsh_fz = #now manacore.meta
