# ============================================================
# sweetdream:equipment/armor/gyre/arc_done —— 回旋·收尾（执行者 = 玩家）
# ------------------------------------------------------------
# 【谁调用它】arc ①（走完 6 步 / 撞墙 99 / 落点 marker 丢失）
# 【顺序】
#   ① 对本次命中的目标额外 24 点固定伤害（**无条件**，撞墙/一步没走也照打）
#   ② 清落点 marker
#   ③ 清状态与临时标签（zx.gyr_st / zx.gyr_t / zx.gyr_p / zx.gyr_done）
# 【★ 标签一定要清干净 ★】zx.gyr_t 用在 target_deal 的选择器上；漏清的话
#   下一次回旋会连带把"上一只"也打一次（静默多打 24 点）。
# ============================================================

# ① 24 点固定伤害（target_deal 自己判目标还在不在）
function sweetdream:equipment/armor/gyre/target_deal

# ② 清落点 marker（三段最多三个，全清）
kill @e[tag=zx.gyr_way,distance=..32]

# ③ 清状态（★ 置 0 = 未激活 ★ core/tick 的选择器是 `zx.gyr_st=1..`，0 不再被选中 ⇒
#   这是整条弧线**唯一的停摆出口**。2026-10-17 事故：tick 曾写成 `0..99`，收尾置 0 后
#   下一刻又被选中、marker 已清 ⇒ 兜底再次收尾 ⇒ 每刻重放音效粒子，死循环。）
scoreboard players set @s zx.gyr_st 0
tag @e[tag=zx.gyr_t,distance=..32] remove zx.gyr_t
tag @e[tag=zx.gyr_done,distance=..32] remove zx.gyr_done
tag @s remove zx.gyr_p

# ④ 收尾表现
execute at @s run particle minecraft:dust{color:[0.25,0.7,0.85],scale:1.5} ~ ~0.5 ~ 0.6 0.5 0.6 0.02 14 normal
execute at @s run playsound minecraft:entity.player.attack.sweep player @a ~ ~ ~ 0.8 1.2
