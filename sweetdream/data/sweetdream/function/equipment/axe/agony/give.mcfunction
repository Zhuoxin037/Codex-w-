# ============================================================
# sweetdream:equipment/axe/agony/give —— 给一件「苦痛」（斧）
# ------------------------------------------------------------
# 【custom_data】
#   "agony" -> 装备 id, 进度 / 被动判定靠它认人
#   ★ 判定一律写成 custom_data~{zx:["agony"]}(部分匹配 + 独有标记)
#   ★ 语义标签 = custom_data.tags(批 A; 词表/逐件表见 .workbuddy/_tags_data.py)
# 【数值要和 cast 对上】魔力 600 / 冷却 100 秒 / 持续 15 秒。
# 【要处理"传递"】目标中途死亡要把效果转给离它最近的那一只,
#   所以每秒都要重新找一次目标, 不能只在施法时记一次 uuid。
#
# 【这个文件是生成的】改描述/数值请改 .workbuddy/_gen_batch5.py 再重跑,
#   然后跑 `python .workbuddy/lore_fmt.py --write` 让规范器重新折行。
# ============================================================
give @s netherite_axe[item_model="sweetdream:agony",item_name={text:"苦痛",bold:true,color:dark_purple},lore=[{"text":"✦ 主动技能","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"魔力 ","color":"gray"},{"text":"600","color":"aqua"},{"text":"   ·   ","color":"dark_gray"},{"text":"冷却 ","color":"gray"},{"text":"100 秒","color":"yellow"}]},{"text":" ","italic":false},{"text":"使用后召唤一个术阵。之后使离自身最近","color":"gray","italic":false},{"text":"的一个生物每秒受到相当于释放者基础攻","color":"gray","italic":false},{"text":"击力 ×2 的伤害。若持续期间该生物死亡","color":"gray","italic":false},{"text":"则对其 2 格内的全部生物造成一次相当于","color":"gray","italic":false},{"text":"其最大生命值的伤害，之后使该效果延续","color":"gray","italic":false},{"text":"到离它最近的一个生物上。该效果持续 15","color":"gray","italic":false},{"text":"秒。","color":"gray","italic":false}],unbreakable={},custom_data={zx:["agony","axe","itemreplace"],skill:"sweetdream:agony",tags:["max_hp","base_atk","formation"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"},tooltip_display={hidden_components:["unbreakable"]}]
