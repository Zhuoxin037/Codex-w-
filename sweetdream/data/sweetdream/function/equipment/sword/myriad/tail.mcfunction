# ============================================================
# sweetdream:equipment/sword/myriad/tail —— 放完一次技能之后的公共收尾
# ------------------------------------------------------------
# 【谁调用它】两把刀 cast 的末尾、以及特殊技能分支(special)之后
# 【执行者】玩家   【前置】
#   · @s zx.mq_ol  = 1 才走超限那几条(没超限就只有"清标签"这一句)
#   · zx.mq_dmg    = 本次技能真正打到的生物(用完即清)
#   · #mq_echo     = 本次技能的**单次**伤害(居合回声要用)
#   · #mq_sw       = 1 表示本次"切换了形态"(居合的延长/增伤以切换为触发)
# 【★ 四条的顺序是锁死的 ★】
#   ① ju_extend 必须在 ju_check **之前** —— 否则刚进居合的那一刀会顺手 +1 秒,
#      3 秒变成 4 秒; 文案的"进入 3 秒"是**拉满**不是"3 + 本次"。
#   ② ju_check    必须在 soul_clear **之前** —— 判据是"剑魂 == 5", 清完就不可能等于 5。
#   ③ soul_clear  放最后 —— 它只减"本次之前"那批, 本次新攒的留着。
#   ④ soul_clear  **只在"主动放千散"时跑** —— 主动放万念不清、被动窗口不清。
#      (2026-10-08 用户定稿; 本条原先只卡"主动", 被"用万念也清"的反馈收窄)
#      依据是文案自己把两种施法分开了:
#        · "自身若**主动**使用了本武器技能则『剑魂』在技能结束后清除"
#        · "若自身有 5 个『剑魂』且**被动或主动**使用了该技能则进入 3 秒「居合」状态"
#      后一句特意写"被动或主动", 前一句只写"主动" ⇒ 清净那条**只管主动**。
#      ★ 至于"本武器" —— 剑魂整套机制(召唤 / 每魂重复一次 / 清除 / 居合)只写在
#        【千散】那段描述里, 万念那段通篇没提剑魂 ⇒ 用户定稿 "本武器" = 千散。
#        所以主动放万念**不再**清(老实现按"两形态一起算", 用万念会把攒的全清光)。
#      两道门控各由一个"本次施法"的假玩家标记提供, 都在本函数末尾复位:
#        · #mq_qs  = 1 表示本次打的是**千散口径**(qiansan/cast 设 1 / myriad/cast 设 0 /
#                    special_go 按 #mq_isq 抄)
#        · #mq_pas = 1 表示本次是**被动兑现**(special 里设)
# ============================================================

execute if score @s zx.mq_ol matches 1 if score #mq_sw zx.meta matches 1 run function sweetdream:equipment/sword/myriad/ju_extend
execute if score @s zx.mq_ol matches 1 run function sweetdream:equipment/sword/myriad/ju_echo
execute if score @s zx.mq_ol matches 1 run function sweetdream:equipment/sword/myriad/ju_check

# ④ 清剑魂 —— ★ 两道门控: 必须"主动" + 必须"千散口径" ★ (2026-10-08 用户定稿)
#   ① `if score #mq_qs zx.meta matches 1`  —— 本次打的是千散(主动放万念时为 0)
#   ② `unless score #mq_pas zx.meta matches 1` —— 不是被动兑现的特殊技能窗口
#   ⚠️ 两条都写成**正判**(`matches 1`): #mq_qs / #mq_pas 是假玩家分,
#      **没被 set 过**时 `matches 0` 不成立(见 RULES「没分数≠0」),
#      写成 `if ... matches 0` 会让"主动放万念"反过来清剑魂 —— 正是本次要修的现象。
execute if score @s zx.mq_ol matches 1 if score #mq_qs zx.meta matches 1 unless score #mq_pas zx.meta matches 1 run function sweetdream:equipment/sword/myriad/soul_clear

tag @e[tag=zx.mq_dmg] remove zx.mq_dmg

# 复位本次施法的两个通道标记: 它们只描述"这一发", 用完清掉, 免得漏给下一次
scoreboard players set #mq_qs zx.meta 0
scoreboard players set #mq_pas zx.meta 0
