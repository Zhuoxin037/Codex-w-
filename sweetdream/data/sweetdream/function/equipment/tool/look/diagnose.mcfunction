# ============================================================
# sweetdream:equipment/tool/look/diagnose —— 观测镜自检
# ------------------------------------------------------------
# 【用法】/function sweetdream:equipment/tool/look/diagnose
# 【它查什么】
#   ① 主手有没有东西
#   ② 主手是不是"带观测镜标记"的那件(即 custom_data.zx 里有 look)
#   ③ 面板开关(test_look_on)   ④ 待回手标记(test_look_pending)
# 【怎么读结果】
#   · ② 是"否" -> 你手里拿的根本不是观测镜(或者组件被改坏了)
#   · 右键之后 ④ 应该"闪一下 1 然后回 0"。**一直是 0 = 进度没触发** ——
#     去检查 advancement/equipment/tool/look.json 的条件:
#     它以前写死了 "items": "minecraft:paper", 换底材后就会永远匹配不上,
#     表现是"右键把道具消耗掉了, 但没人把它还回来"。(踩过一次, 已修)
# ============================================================

tellraw @s [{"text":"===== 观测镜自检 =====","color":"gold"}]

execute if data entity @s SelectedItem run tellraw @s [{"text":"① 主手有东西: 是","color":"gray"}]
execute unless data entity @s SelectedItem run tellraw @s [{"text":"① 主手是空的","color":"red"}]

execute if data entity @s SelectedItem.components."minecraft:custom_data"{zx:["look"]} run tellraw @s [{"text":"② 主手带着观测镜标记 zx:[\"look\"]: 是","color":"green"}]
execute unless data entity @s SelectedItem.components."minecraft:custom_data"{zx:["look"]} run tellraw @s [{"text":"② 主手不是观测镜(或没带标记)","color":"yellow"}]

scoreboard players set #d_on zx.meta 0
scoreboard players set #d_pend zx.meta 0
execute if entity @s[tag=test_look_on] run scoreboard players set #d_on zx.meta 1
execute if entity @s[tag=test_look_pending] run scoreboard players set #d_pend zx.meta 1
tellraw @s [{"text":"③ 面板开着(test_look_on): ","color":"gray"},{"score":{"name":"#d_on","objective":"zx.meta"},"color":"yellow"}]
tellraw @s [{"text":"④ 待回手(test_look_pending): ","color":"gray"},{"score":{"name":"#d_pend","objective":"zx.meta"},"color":"yellow"}]

tellraw @s [{"text":"读法: 右键后 ④ 应该闪一下 1; 一直是 0 就说明进度没触发","color":"dark_gray"}]
