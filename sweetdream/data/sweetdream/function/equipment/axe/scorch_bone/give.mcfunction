# ============================================================
# sweetdream:equipment/axe/scorch_bone/give —— 给一件「焦骨」（斧）
# ------------------------------------------------------------
# 【custom_data】
#   "scorch_bone" -> 装备 id, 进度 / 被动判定靠它认人
#   ★ 判定一律写成 custom_data~{zx:["scorch_bone"]}(部分匹配 + 独有标记)
#   ★ 语义标签 = custom_data.tags(批 A; 词表/逐件表见 .workbuddy/_tags_data.py)
# 【主动】160 / 28 秒 -> 打 6 格内最近目标 基础攻击力 ×5, 并对其周围 2 格 最大魔力 ×0.05;
#   主目标有「流火」-> 转「夜火」+ 返 40 魔力; 主目标原本已是「夜火」-> 范围伤提到 最大魔力 ×0.1。
#
# 【这个文件是生成的】改描述/数值请改 .workbuddy/_gen_batch7.py 再重跑,
#   然后跑 `python .workbuddy/lore_fmt.py --write` 让规范器重新折行。
# ★ 本批只做 give（2026-10-11 用户定）: 技能 / 进度 / 外观 等后续批次再接。
# ★ 本批**不挂 item_model**（外观未做; 挂了会引用不存在的模型 -> 游戏里显示紫黑方块）。
#   外观批次再补 item_model="sweetdream:scorch_bone" + items/*.json + models/ + 贴图。
# ============================================================
give @s diamond_axe[item_name={text:"焦骨",bold:true,color:dark_gray},lore=[{"text":"✦ 主动技能","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"魔力 ","color":"gray"},{"text":"160","color":"aqua"},{"text":"   ·   ","color":"dark_gray"},{"text":"冷却 ","color":"gray"},{"text":"28 秒","color":"yellow"}]},{"text":" ","italic":false},{"text":"攻击 6 格内最近一个目标，造成相当于自","color":"gray","italic":false},{"text":"身基础攻击力 ×5 的伤害，并对其周围 2","color":"gray","italic":false},{"text":"格造成最大魔力 ×0.05 伤害。若主目标拥","color":"gray","italic":false},{"text":"有「流火」，则将其「流火」转化为","color":"gray","italic":false},{"text":"「夜火」，并返还 40 魔力；若主目标原","color":"gray","italic":false},{"text":"本已经拥有「夜火」，则改为将范围伤害","color":"gray","italic":false},{"text":"提高至相当于自身最大魔力 ×0.1。","color":"gray","italic":false}],unbreakable={},custom_data={zx:["scorch_bone","axe","itemreplace"],skill:"sweetdream:scorch_bone",tags:["liuhuo","yehuo","base_atk","max_mana","apply","consume"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"},tooltip_display={hidden_components:["unbreakable"]}]
