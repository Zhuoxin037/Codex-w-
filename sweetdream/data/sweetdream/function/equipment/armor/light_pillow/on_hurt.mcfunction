# ============================================================
# sweetdream:equipment/armor/light_pillow/on_hurt —— 轻枕: 被"做梦的"生物近战打 -> 抗性
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:equipment/armor/light_pillow_hurt
#   触发器 entity_hurt_player，条件 damage.type.tags 含 sweetdream:melee_damage
#   （本包自己定义的近战标签 = mob_attack / mob_attack_no_aggro / player_attack）
# 【执行者】玩家（挨打的那个人）
# 【文案(lore 逐字)】自身魔力值上限 +40。受到原本附有「白昼梦」的生物造成的近战伤害后，
#   获得 2 秒抗性提升Ⅰ。该效果 4 秒内最多触发一次。
# ※ 原文写的是"**原本**附有" —— 轻枕自己不消耗任何状态，所以"原本"= 挨打那一刻就带着。
# ============================================================
# 【★ 一处实现近似, 必须知道 ★】"打我的是谁"在数据包侧**读不到**：
#   · 原版不给玩家记"最近打我的是谁"（不像生物有 last_hurt_by_player）；
#   · 进度只能**过滤**、不能把实体传进奖励函数。
#   ⇒ 按文案自己的约束近似成"**3 格内最近的、带「白昼梦」的生物**"。
#     近战本来就贴身, 所以这个近似在实战里基本等价; 少数情况(旁边另一只带白昼梦的
#     生物更近)会误判 —— 已按"宁可触发也别没效果"的口径取舍, 记在这里备查。
# ============================================================

advancement revoke @s only sweetdream:equipment/armor/light_pillow_hurt

# ① 没穿轻枕就没这事（靴子）
execute unless items entity @s armor.feet *[minecraft:custom_data~{zx:["light_pillow"]}] run return 0

# ② 4 秒节流
scoreboard players set #lp_due zx.meta 0
execute store result score #lp_due zx.meta run scoreboard players get @s zx.lpillow_cd
execute if score #lp_due zx.meta > #now manacore.meta run return 0

# ③ 找那只"做梦的"（3 格内最近、带「白昼梦」）
tag @e[tag=zx.lp_s,distance=0..] remove zx.lp_s
execute at @s run tag @e[type=!#sweetdream:no_damage,distance=..3,tag=zx.status.dream,sort=nearest,limit=1] add zx.lp_s
execute unless entity @e[tag=zx.lp_s,distance=0..,limit=1] run return 0

# ④ 获得 2 秒抗性提升Ⅰ
effect give @s minecraft:resistance 2 0 true

# ⑤ 表现 + 记账 + 收尾
execute at @s run particle minecraft:effect ~ ~1 ~ 0.3 0.4 0.3 0.0 6 normal
execute at @s run playsound minecraft:block.wool.place player @a ~ ~ ~ 0.5 1.4
scoreboard players operation @s zx.lpillow_cd = #now manacore.meta
scoreboard players operation @s zx.lpillow_cd += #80 zx.meta
tag @e[tag=zx.lp_s,distance=0..] remove zx.lp_s
