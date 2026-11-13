# ============================================================
# sweetdream:equipment/armor/long_blessing/on_pay —— 一次成功付费到达这里
# ------------------------------------------------------------
# 【谁调用】long_blessing/tick ②（本刻出现新的 zx.j_pay_t 时）
# 【执行者】付费的玩家
# 【文案口径】
#   · 头盔被动：成功施放**实际消耗不少于 240 魔力**的武器主动技能后,
#     为 8 格内生命比例最低的受伤玩家赋予 12 秒「长祝」(覆盖式刷新)。
#   · 长祝：持有者成功施放**一次实际付费**的武器主动技能后, 剩余时间 +2 秒,
#     最多 4 次。
# 【★ 两分支互斥 ★】穿头盔且单笔 ≥240 时走"赋予"(apply 会重置 lb_ext)，
#   同一次付费不再顺手延长；否则持有长祝就延长。
# 【单位】zx.j_paid = 魔力 ×1000 毫魔力点 ⇒ 240 魔力 = 240000。
# ============================================================

scoreboard players set #lb_grant zx.meta 0
execute if score @s zx.j_paid matches 240000.. if items entity @s armor.head *[minecraft:custom_data~{zx:["long_blessing"]}] run scoreboard players set #lb_grant zx.meta 1

execute if score #lb_grant zx.meta matches 1 run function sweetdream:equipment/armor/long_blessing/grant
execute if score #lb_grant zx.meta matches 0 if score @s zx.lb_end matches 1.. if score @s zx.lb_ext matches ..3 run function sweetdream:equipment/armor/long_blessing/extend
