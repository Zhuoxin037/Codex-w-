# ============================================================
# sweetdream:equipment/armor/purge_fire/hurt —— 涤火：被附有「流火」的生物打了之后
# ------------------------------------------------------------
# 【谁调用它】internal/hurt/event.mcfunction 的受伤事件串行分发链（需主对话加一行 hook）
#   建议在 event.mcfunction 的 hurt_evt 分发段（第 17~19 行附近）加：
#   execute if score @s zx.hurt_evt matches 1.. if items entity @s armor.chest *[minecraft:custom_data~{zx:["purge_fire"]}] run function sweetdream:equipment/armor/purge_fire/hurt
#   ★ 注意 event.mcfunction 第 15 行那条总门控的 unless 链里也要补
#     `unless items entity @s armor.chest *[minecraft:custom_data~{zx:["purge_fire"]}]`，
#     否则只穿涤火的玩家会在那一句被 return 0 提前挡掉、整条分发链都不跑。
# 【执行者】受伤的玩家
# 【技能原文（逐字）】
#   最大魔力值 +100，最大生命值 +4。自身受到生物造成的伤害后，若伤害来源附有
#   「流火」，则消耗并恢复自身 10% 的生命值。若伤害来源附有「流火」「夜火」，则
#   消耗并恢复自身 40% 的生命值且自身基础攻击力 +20%，持续 5 秒。两种效果每 8 秒
#   最多触发一次。
# 【读法】
#   · "伤害来源" = 3 格→6 格内最近的、附有「流火」的非玩家生物。进度只报"玩家
#     受伤"、不给攻击者实体，照 blaze_armor/hurt 的近似（远程箭伤害按找不到处理）。
#   · "附有「流火」「夜火」" = 同一只攻击者同时带 zx.status.liuhuo 与
#     zx.status.yehuo；优先走 40% 档，一次受伤只结算一档。
#   · "消耗" = 第一档摘该攻击者的「流火」；第二档摘「流火」+「夜火」，走
#     lib/mark_consume（装备被动消耗，src:"equip"）。
#   · "两种效果每 8 秒最多触发一次" = 两档共用一个节流 zx.pf_cd（= 下次可触发刻）。
#   · 最大魔力值 +100 / 最大生命值 +4 由 give 的组件负责，本文件不写。
# ============================================================

# ① 穿着门控（盔甲被动，函数体第一行）
execute unless items entity @s armor.chest *[minecraft:custom_data~{zx:["purge_fire"]}] run return 0

# ② 8 秒共用节流（zx.pf_cd = 下次可触发刻；160 刻 = 8 秒）
scoreboard players add @s zx.pf_cd 0
execute if score @s zx.pf_cd > #now manacore.meta run return 0

# ③ 找伤害来源：3 格内最近的、带「流火」的非玩家生物；没有则放宽到 6 格
#   ★ 全部显式 at @s，给 distance 一个玩家位置基准（进度奖励函数的执行位置不可靠）
execute at @s run tag @e[tag=zx.pf_src,distance=0..] remove zx.pf_src
execute at @s run tag @e[type=!#sweetdream:no_damage,distance=..3,tag=zx.status.liuhuo,sort=nearest,limit=1] add zx.pf_src
execute at @s unless entity @e[tag=zx.pf_src,distance=0..,limit=1] run tag @e[type=!#sweetdream:no_damage,distance=..6,tag=zx.status.liuhuo,sort=nearest,limit=1] add zx.pf_src
execute at @s unless entity @e[tag=zx.pf_src,distance=0..,limit=1] run return 0

# ④ 分档：这只攻击者是否同时带「夜火」
scoreboard players set #pf_both zx.meta 0
execute at @s if entity @e[tag=zx.pf_src,tag=zx.status.yehuo,distance=0..,limit=1] run scoreboard players set #pf_both zx.meta 1

# ⑤ 消耗 + 恢复 + 基础攻击力加成（都在 at @s 语境里，@e 选择器位置基准正确）
execute at @s run function sweetdream:equipment/armor/purge_fire/resolve

# ⑥ 记账节流 + 表现 + 收尾
scoreboard players operation @s zx.pf_cd = #now manacore.meta
scoreboard players add @s zx.pf_cd 160
execute at @s run particle minecraft:flame ~ ~1 ~ 0.3 0.4 0.3 0.02 10 normal
execute at @s run tag @e[tag=zx.pf_src,distance=0..] remove zx.pf_src
