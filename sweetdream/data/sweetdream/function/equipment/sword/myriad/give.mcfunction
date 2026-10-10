# ============================================================
# sweetdream:equipment/sword/myriad/give —— 给一件「万念」（剑）
# ------------------------------------------------------------
# 【custom_data】
#   "myriad" -> 装备 id, 进度 / 被动判定靠它认人
#   ★ 判定一律写成 custom_data~{zx:["myriad"]}(部分匹配 + 独有标记)
#   ★ 语义标签 = custom_data.tags(批 A; 词表/逐件表见 .workbuddy/_tags_data.py)
# 【切换】使用后把自己换成「千散」(qiansan); 千散用完再换回万念。
#   两把是同一把武器的一体两面, 所以冷却/魔力都要一致。
# 【数值要和 cast 对上】魔力 80 / 冷却 20 秒。
#
# 【这个文件是生成的】改描述/数值请改 .workbuddy/_gen_batch5.py 再重跑,
#   然后跑 `python .workbuddy/lore_fmt.py --write` 让规范器重新折行。
# ============================================================
give @s iron_sword[item_model="sweetdream:myriad",item_name={text:"万念",bold:true,color:white},lore=[{"text":"✦ 主动技能","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"魔力 ","color":"gray"},{"text":"80","color":"aqua"},{"text":"   ·   ","color":"dark_gray"},{"text":"冷却 ","color":"gray"},{"text":"20 秒","color":"yellow"}]},{"text":" ","italic":false},{"text":"使用后切换为「千散」并对自身 3 格内的","color":"gray","italic":false},{"text":"全部生物造成一次相当于自身当前魔力值","color":"gray","italic":false},{"text":"×0.1 的伤害。","color":"gray","italic":false}],unbreakable={},custom_data={zx:["myriad","sword","itemreplace"],skill:"sweetdream:myriad",tags:["cur_mana"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"},tooltip_display={hidden_components:["unbreakable"]}]
