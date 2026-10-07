# ============================================================
# sweetdream:equipment/staff/final_revelation/end —— 光柱结束的收尾
# ------------------------------------------------------------
# 【谁调用它】tick ⑥ —— 倒计时扣到 0 的那一秒。
# 【两件事】
#   ① 主动释放(zx.fr_auto = 0) -> 再对范围内生物打一次 最大魔力 ×0.2
#   ② 清掉临时标签 + 复位 fr_auto
# 【为什么要"再扫一次"】光柱是跟随玩家的, 结束那一刻的范围要用**当刻**的位置/朝向
#   重新算 —— 不能沿用上一秒的标签(玩家可能已经转身/移动)。
# 【为什么自动释放没有 ×0.2】文案: "若为主动释放，则在结束后再对范围内的生物
#   造成一次…" —— 只有主动释放有。
# ============================================================

# ① 按当刻位置/朝向重扫一次(覆盖掉上一秒的标签)
function sweetdream:equipment/staff/final_revelation/scan

# ② 主动释放 -> 收尾一击(最大魔力 ×0.2)
execute if score @s zx.fr_auto matches 0 run function sweetdream:equipment/staff/final_revelation/end_blast

# ③ 清临时标签 + 复位"是不是自动释放"
tag @e[tag=zx.fr_in,distance=0..] remove zx.fr_in
scoreboard players set @s zx.fr_auto 0
