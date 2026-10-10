# ============================================================
# sweetdream:equipment/axe/red_lotus/give —— 给一件「红莲」（斧）
# ------------------------------------------------------------
# 【custom_data】
#   "red_lotus" -> 装备 id, 进度 / 被动判定靠它认人
#   ★ 判定一律写成 custom_data~{zx:["red_lotus"]}(部分匹配 + 独有标记)
#   ★ 语义标签 = custom_data.tags(批 A; 词表/逐件表见 .workbuddy/_tags_data.py)
# 【数值要和 cast 对上】魔力 80 / 冷却 30 秒。消耗自身 5 格内生物的「流火」/「夜火」。
#   每层「流火」-> 5 格内 1 倍基础攻击力一次; 每层「夜火」-> 6 格内 ×3 一次。
#
# 【这个文件是生成的】改描述/数值请改 .workbuddy/_gen_batch6.py 再重跑,
#   然后跑 `python .workbuddy/lore_fmt.py --write` 让规范器重新折行。
# ============================================================
give @s iron_axe[item_model="sweetdream:red_lotus",item_name={text:"红莲",bold:true,color:red},lore=[{"text":"✦ 主动技能","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"魔力 ","color":"gray"},{"text":"80","color":"aqua"},{"text":"   ·   ","color":"dark_gray"},{"text":"冷却 ","color":"gray"},{"text":"30 秒","color":"yellow"}]},{"text":" ","italic":false},{"text":"使用后消耗自身 5 格内全部生物的","color":"gray","italic":false},{"text":"「流火」或「夜火」效果。之后每消耗一","color":"gray","italic":false},{"text":"层「流火」则对自身 5 格内的生物造成一","color":"gray","italic":false},{"text":"次相当于自身基础攻击力的伤害，每消耗","color":"gray","italic":false},{"text":"一层「夜火」则对自身 6 格内的生物造成","color":"gray","italic":false},{"text":"一次相当于自身基础攻击力 ×3 的伤害。","color":"gray","italic":false}],unbreakable={},custom_data={zx:["red_lotus","axe","itemreplace"],skill:"sweetdream:red_lotus",tags:["liuhuo","yehuo","base_atk","consume"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"},tooltip_display={hidden_components:["unbreakable"]}]
