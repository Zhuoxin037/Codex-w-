# ============================================================
# sweetdream:equipment/armor/fade/on_cast —— 息影: 记一次"刚放过技能"
# ------------------------------------------------------------
# 【谁调用它】#manacore:event/cooldown_start(前置包每次技能进入冷却时抛出;
#   本包所有主动技能都是"扣完蓝之后"才记冷却 -> 此刻 @s 就是施法者本人)
# 【做什么】把倒计时重新拉满 10 秒。到点由 fade/passive 兑现。
# 【技能原文(lore 逐字)】
#   "自身魔力值上限 +90。自身释放技能后若在 10 秒内没有再次释放技能则使当前
#    手持装备冷却时间 -10 秒且自身恢复 50 魔力值。"
# 【为什么是"拉满"而不是"加一层"】文案是"10 秒内**没有再次**释放", 是**最后一次
#   施法**之后的 10 秒; 连放只会把倒计时不断刷回 10 秒, 不会叠加兑现次数。
# ============================================================

execute unless entity @s[type=minecraft:player] run return 0

# 穿着门控(认装备用 ~ 部分匹配 + 独有标记)
execute unless items entity @s armor.legs *[minecraft:custom_data~{zx:["fade"]}] run return 0

scoreboard players set @s zx.fd_t 10
