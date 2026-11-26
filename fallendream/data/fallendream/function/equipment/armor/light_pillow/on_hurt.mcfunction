# ============================================================
# fallendream:equipment/armor/light_pillow/on_hurt —— 轻枕: 被"做梦的"生物近战打 -> 抗性
# ------------------------------------------------------------
# 【谁调用它】进度 fallendream:equipment/armor/light_pillow_hurt
#   触发器 entity_hurt_player，条件 damage.type.tags 含 fallendream:melee_damage
#   （本包自己定义的近战标签 = mob_attack / mob_attack_no_aggro / player_attack）
# 【执行者】玩家（挨打的那个人）
# 【文案(lore 逐字 · 基础)】自身魔力值上限 +40。受到原本附有「白昼梦」的生物造成的近战
#   伤害后，获得 2 秒抗性提升Ⅰ。该效果 4 秒内最多触发一次。
# 【文案(lore 逐字 · 超限)】自身魔力值上限 +120。受到原本附有「白昼梦」的生物造成的
#   近战伤害后，获得 5 秒抗性提升Ⅲ及迅捷Ⅱ，之后使攻击自身的生物时停 1 秒。
#   该效果 3 秒内最多触发一次。
# ※ 原文写的是"**原本**附有" —— 轻枕自己不消耗任何状态，所以"原本"= 挨打那一刻就带着。
# ============================================================
# 【★ 一处实现近似, 必须知道 ★】"打我的是谁"在数据包侧**读不到**：
#   · 原版不给玩家记"最近打我的是谁"（不像生物有 last_hurt_by_player）；
#   · 进度只能**过滤**、不能把实体传进奖励函数。
#   ⇒ 按文案自己的约束近似成"**3 格内最近的、带「白昼梦」的生物**"。
#     近战本来就贴身, 所以这个近似在实战里基本等价; 少数情况(旁边另一只带白昼梦的
#     生物更近)会误判 —— 已按"宁可触发也别没效果"的口径取舍, 记在这里备查。
#     ★ 超限的"使攻击自身的生物时停"也只能落在同一只近似目标上。★
# ============================================================

advancement revoke @s only fallendream:equipment/armor/light_pillow_hurt

# ① 没穿轻枕就没这事（靴子）
execute unless items entity @s armor.feet *[minecraft:custom_data~{zx:["light_pillow"]}] run return 0

# ①.5 档位快照（节流长度、抗性秒数/等级、迅捷与时停都是分档的）
scoreboard players set #lp_ol zx.meta 0
execute if items entity @s armor.feet *[minecraft:custom_data~{zx:["light_pillow"],ol:"light_pillow"}] run scoreboard players set #lp_ol zx.meta 1

# ② 节流: 基础 4 秒 / 超限 3 秒
scoreboard players set #lp_gap zx.meta 80
execute if score #lp_ol zx.meta matches 1 run scoreboard players set #lp_gap zx.meta 60
scoreboard players set #lp_due zx.meta 0
execute store result score #lp_due zx.meta run scoreboard players get @s zx.lpillow_cd
execute if score #lp_due zx.meta > #now manacore.meta run return 0

# ③ 找那只"做梦的"（3 格内最近、带「白昼梦」）
tag @e[tag=zx.lp_s,distance=0..] remove zx.lp_s
execute at @s run tag @e[type=!#fallendream:no_damage,distance=..3,tag=zx.status.dream,sort=nearest,limit=1] add zx.lp_s
execute unless entity @e[tag=zx.lp_s,distance=0..,limit=1] run return 0

# ④ 抗性: 基础 2 秒Ⅰ / 超限 5 秒Ⅲ；超限再加 5 秒迅捷Ⅱ
#   ★ 两档各写一条 effect, 不要 clear 再给 —— clear 会把别处给的同名效果一起抹掉。
execute if score #lp_ol zx.meta matches 0 run effect give @s minecraft:resistance 2 0 true
execute if score #lp_ol zx.meta matches 1 run effect give @s minecraft:resistance 5 2 true
execute if score #lp_ol zx.meta matches 1 run effect give @s minecraft:speed 5 1 true

# ⑤ ★ 超限: "之后使攻击自身的生物时停 1 秒" ★
#   目标 = ③ 圈出来的那只（就是近似意义上的"攻击者"）。走 lib/timestop 统一口径。
execute if score #lp_ol zx.meta matches 1 run data modify storage zx:work fz set value {target:"@e[tag=zx.lp_s]",ticks:20}
execute if score #lp_ol zx.meta matches 1 run function fallendream:lib/timestop with storage zx:work fz

# ⑥ 表现 + 记账 + 收尾
execute at @s run particle minecraft:effect ~ ~1 ~ 0.3 0.4 0.3 0.0 6 normal
execute at @s run playsound minecraft:block.wool.place player @a ~ ~ ~ 0.5 1.4
scoreboard players operation @s zx.lpillow_cd = #now manacore.meta
scoreboard players operation @s zx.lpillow_cd += #lp_gap zx.meta
tag @e[tag=zx.lp_s,distance=0..] remove zx.lp_s
