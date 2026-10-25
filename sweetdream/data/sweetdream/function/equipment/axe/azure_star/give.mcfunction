# ============================================================
# sweetdream:equipment/axe/azure_star/give —— 给一件「苍蓝星」（斧）
# ------------------------------------------------------------
# 【custom_data】
#   "azure_star" -> 装备 id, 进度 / 被动判定靠它认人
#   ★ 判定一律写成 custom_data~{zx:["azure_star"]}(部分匹配 + 独有标记)
#   ★ 语义标签 = custom_data.tags(批 A; 词表/逐件表见 .workbuddy/_tags_data.py)
# 【被动 + 主动】被动: 当前魔力 >800 时每次攻击 20% 让本武器伤害倍率翻倍（不可叠加）。
#   主动: 500 / 80 秒 -> 最近生物 ×0.5, 之后其 2 格内 ×0.1。
#
# 【这个文件是生成的】改描述/数值请改 .workbuddy/_gen_batch6.py 再重跑,
#   然后跑 `python .workbuddy/lore_fmt.py --write` 让规范器重新折行。
# ============================================================
give @s netherite_axe[item_model="sweetdream:azure_star",item_name={text:"苍蓝星",bold:true,color:blue},lore=[{"text":"✦ 被动技能","color":"gold","bold":true,"italic":false},{"text":"每次攻击若自身当前魔力值高于 800，则","color":"gray","italic":false},{"text":"都有 20% 概率使该武器伤害倍率 +100%","color":"gray","italic":false},{"text":"（不可叠加）。","color":"gray","italic":false},{"text":" ","italic":false},{"text":"✦ 主动技能","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"魔力 ","color":"gray"},{"text":"500","color":"aqua"},{"text":"   ·   ","color":"dark_gray"},{"text":"冷却 ","color":"gray"},{"text":"80 秒","color":"yellow"}]},{"text":" ","italic":false},{"text":"使用后对离自身最近的一个生物造成相当","color":"gray","italic":false},{"text":"于自身最大魔力值 ×0.5 的伤害，之后对","color":"gray","italic":false},{"text":"其 2 格内的生物造成相当于自身最大魔力","color":"gray","italic":false},{"text":"值 ×0.1 的伤害。","color":"gray","italic":false}],unbreakable={},custom_data={zx:["azure_star","axe","itemreplace"],skill:"sweetdream:azure_star",tags:["max_mana","cur_mana","indep_mul"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"},tooltip_display={hidden_components:["unbreakable"]}]
