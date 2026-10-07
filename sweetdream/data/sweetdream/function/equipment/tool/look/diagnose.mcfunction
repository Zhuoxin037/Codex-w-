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

# ⑤ 层数段(xline)现在会拼出什么 —— 现场跑一遍, 把结果打出来看
#   空表 = 你现在没有"在身 + 层数非 0"的东西, 面板就只显示冷却之前那几段。
#   层数段会接在动作栏**冷却后面、同一行**, 用 " ｜ " 分隔。
data remove storage zx:look xline
data modify storage zx:look xline set value []
data remove storage zx:work eq
scoreboard players set #ly_first zx.meta 1
function sweetdream:debug/equip_scan {p:"SelectedItem"}
function sweetdream:debug/equip_scan {p:"equipment.offhand"}
function sweetdream:debug/equip_scan {p:"equipment.head"}
function sweetdream:debug/equip_scan {p:"equipment.chest"}
function sweetdream:debug/equip_scan {p:"equipment.legs"}
function sweetdream:debug/equip_scan {p:"equipment.feet"}
function sweetdream:lib/look/layer_unroll
tellraw @s [{"text":"⑤ 层数段拼出来的组件(空 = 没有层数机制在身):","color":"gray"}]
tellraw @s [{"text":"  原始结构: ","color":"dark_gray"},{"nbt":"xline","storage":"zx:look","color":"aqua"}]
# ★ 空表不能进 interpret:true ★ —— 空列表不是合法组件, 读一次就刷一条
#   "Failed to parse component: []"(观测镜每刻刷一条的元凶, 2026-10-05)。
#   这条只是自检的一次性输出, 用守卫挡掉空表即可(不必像 render_go 那样垫空组件)。
# empty-ok: 下面两行互斥, 空表那条根本不会被 interpret:true 读到
execute if data storage zx:look xline[0] run tellraw @s [{"text":"  渲染效果: ","color":"dark_gray"},{"nbt":"xline","storage":"zx:look","interpret":true}]
execute unless data storage zx:look xline[0] run tellraw @s [{"text":"  渲染效果: (空表 —— 当前没有层数机制在身)","color":"dark_gray"}]

tellraw @s [{"text":"读法: 右键后 ④ 应该闪一下 1; 一直是 0 就说明进度没触发","color":"dark_gray"}]
tellraw @s [{"text":"第二行没东西? 检查手里/身上的装备有没有在 layer 表(lib/reg/build)里登记","color":"dark_gray"}]
