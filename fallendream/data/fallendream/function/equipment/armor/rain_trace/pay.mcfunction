# ============================================================
# fallendream:equipment/armor/rain_trace/pay —— 兑现「停够时长」（执行者 = 水迹实体）
# ------------------------------------------------------------
# 【谁调用它】dot_tick ③（水迹 1.6 格内还有"停留中"的生物时才跑）
# 【技能原文(lore 逐字)】
#   基础: "…对在水迹处持续停留 2 秒的生物附加「渊海」，并使其受到一次相当于
#          释放者基础攻击力 ×2 的伤害。"
#   超限: "自身魔力值上限 +120。…之后对在本次水迹处累计停留 1 秒的生物附加
#          「渊海」，之后不论其有没有在水迹上都会每秒使其受到一次相当于释放者
#          基础攻击力 ×2 的伤害，持续至其停留的水迹消失。"
# 【做什么】
#   ① 逐只判是否停够（基础 40 刻 / 超限 20 刻，见 pay_one）→ 打 zx.rt_pay
#   ② 附「渊海」（tag/mark）
#   ③ 结算伤害：
#        · 基础 = **一次**（出生时算好，存在水迹点 NBT）→ pay_once
#        · 超限 = **每秒一次，直到这摊水迹消失** → ol_link 挂标记，
#          由 dot_tick 的每秒节拍去打（见 ol_dot）
#   ④ 把这只置 zx.rt_on = 2（本段水迹对同一只**只结算一次**）
# 【★ 顺序：先附状态、后打伤害 ★】文案写的顺序如此；而且「渊海」是很多装备的
#   触发条件（回潮扣/杂纹/彼岸…），先附上再让这一下伤害进 calc 链，语义才一致。
# 【★ 伤害归属 ★】水迹 NBT 里存了释放者 UUID 四整数，交给 with_from 做 by 归属；
#   玩家中途离线时 with_from 会退回"无归属"的写法（不会静默丢伤害）。
# 【★ #rt_olp 为什么要先抄到假玩家 ★】pay_one 是 `as <生物>` 进去的，那时 @s
#   已经不是水迹点、读不到它的 zx.rt_ol；停留门槛要按水迹点的档位算，所以先抄一份。
# ============================================================

tag @e[tag=zx.rt_pay,distance=..16] remove zx.rt_pay
scoreboard players operation #rt_olp zx.meta = @s zx.rt_ol
execute as @e[type=!#fallendream:no_damage,distance=..1.6,scores={zx.rt_on=1}] run function fallendream:equipment/armor/rain_trace/pay_one
execute unless entity @e[tag=zx.rt_pay,distance=..16] run return 0

# ① 附「渊海」
data modify storage zx:work t set value {target:"@e[tag=zx.rt_pay,distance=..16]",mark:"yuanhai"}
function fallendream:tag/mark with storage zx:work t

# ② 伤害分流：超限挂"持续伤害"，基础打一次性
execute if score #rt_olp zx.meta matches 1 run function fallendream:equipment/armor/rain_trace/ol_link
execute unless score #rt_olp zx.meta matches 1 run function fallendream:equipment/armor/rain_trace/pay_once

# ③ 本段水迹对这只不再重复结算
scoreboard players set @e[tag=zx.rt_pay,distance=..16] zx.rt_on 2

# ④ 表现
execute at @e[tag=zx.rt_pay,distance=..16] run particle minecraft:splash ~ ~0.4 ~ 0.4 0.4 0.4 0 12 normal
execute at @e[tag=zx.rt_pay,distance=..16] run particle minecraft:dust{color:[0.3,0.55,0.75],scale:1.2} ~ ~0.5 ~ 0.3 0.3 0.3 0 8 normal
execute at @e[tag=zx.rt_pay,distance=..16] run playsound minecraft:entity.player.splash player @a ~ ~ ~ 0.7 1.0

tag @e[tag=zx.rt_pay,distance=..16] remove zx.rt_pay
