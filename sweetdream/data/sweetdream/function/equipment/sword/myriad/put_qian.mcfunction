# ============================================================
# sweetdream:equipment/sword/myriad/put_qian —— 把手里的「万念」换成「千散」
# ------------------------------------------------------------
# 【这个文件是生成的】改数值/描述请改 .workbuddy/_gen_batch5.py,
#   然后重跑 `python .workbuddy/_gen_swap.py`(组件串必须和 give 一致,
#   见本脚本头注释)。
#
# 【执行者】玩家本人(@s)   【谁调用它】equipment/<...>/swap(延迟几 tick 之后)
# 【主手 / 副手】和通用回手线同一套判据: 先看主手, 主手不是再看副手。
#   item replace 是覆盖式的 —— 写错槽位就等于把玩家那件装备吃掉, 所以
#   判据必须写全, 而且"两把都不是"时下面两条都不成立(安静地什么都不做)。
# ============================================================

# ① 主手是万念 -> 换主手
execute if items entity @s weapon.mainhand iron_sword[minecraft:custom_data~{zx:["myriad"]}] run item replace entity @s weapon.mainhand with iron_sword[item_name={text:"千散",bold:true,color:dark_red},lore=[{"text":"✦ 主动技能","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"魔力 ","color":"gray"},{"text":"80","color":"aqua"},{"text":"   ·   ","color":"dark_gray"},{"text":"冷却 ","color":"gray"},{"text":"20 秒","color":"yellow"}]},{"text":" ","italic":false},{"text":"使用后切换为「万念」并对自身 3 格内的","color":"gray","italic":false},{"text":"全部生物造成一次相当于自身基础攻击力","color":"gray","italic":false},{"text":"×2 的伤害。","color":"gray","italic":false}],unbreakable={},custom_data={zx:["qiansan","sword","itemreplace"],skill:"sweetdream:qiansan"},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"},tooltip_display={hidden_components:["unbreakable"]}]
execute if items entity @s weapon.mainhand iron_sword[minecraft:custom_data~{zx:["qiansan"]}] at @s run playsound minecraft:item.armor.equip_iron player @a ~ ~ ~ 0.6 1.8

# ② 主手不是、副手是万念 -> 换副手
execute unless items entity @s weapon.mainhand iron_sword[minecraft:custom_data~{zx:["myriad"]}] if items entity @s weapon.offhand iron_sword[minecraft:custom_data~{zx:["myriad"]}] run item replace entity @s weapon.offhand with iron_sword[item_name={text:"千散",bold:true,color:dark_red},lore=[{"text":"✦ 主动技能","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"魔力 ","color":"gray"},{"text":"80","color":"aqua"},{"text":"   ·   ","color":"dark_gray"},{"text":"冷却 ","color":"gray"},{"text":"20 秒","color":"yellow"}]},{"text":" ","italic":false},{"text":"使用后切换为「万念」并对自身 3 格内的","color":"gray","italic":false},{"text":"全部生物造成一次相当于自身基础攻击力","color":"gray","italic":false},{"text":"×2 的伤害。","color":"gray","italic":false}],unbreakable={},custom_data={zx:["qiansan","sword","itemreplace"],skill:"sweetdream:qiansan"},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"},tooltip_display={hidden_components:["unbreakable"]}]
execute unless items entity @s weapon.mainhand iron_sword[minecraft:custom_data~{zx:["myriad"]}] if items entity @s weapon.offhand iron_sword[minecraft:custom_data~{zx:["qiansan"]}] at @s run playsound minecraft:item.armor.equip_iron player @a ~ ~ ~ 0.6 1.8

# 【声音为什么跟在 replace 后面、判的是"换完之后"的新物品】放到上层 swap 里
#   无条件响的话, 万一这两条都没匹配上(玩家这 3 tick 里把剑丢了), 就会
#   "没换手却响一声" —— 比不响更误导。判新物品则天然只在换成了时才响。
