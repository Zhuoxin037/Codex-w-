# ============================================================
# sweetdream:equipment/axe/anchor/give —— 给一件「沉锚」（斧）
# ------------------------------------------------------------
# 【custom_data】
#   "anchor" -> 装备 id, 进度 / 被动判定靠它认人
#   ★ 判定一律写成 custom_data~{zx:["anchor"]}(部分匹配 + 独有标记)
#   ★ 语义标签 = custom_data.tags(批 A; 词表/逐件表见 .workbuddy/_tags_data.py)
# 【被动 + 主动】被动: 攻击 10% -> 前方 1 格内生物击飞 1 格 + 最大魔力 ×0.06。
#   主动: 200 / 12 秒 -> 向 10 格内准星目标掷锚并位移过去, 落点 2 格内 基础攻击力 ×5 且击飞 2 格。
#
# 【这个文件是生成的】改描述/数值请改 .workbuddy/_gen_batch7.py 再重跑,
#   然后跑 `python .workbuddy/lore_fmt.py --write` 让规范器重新折行。
# ★ 本批只做 give（2026-10-11 用户定）: 技能 / 进度 / 外观 等后续批次再接。
# ★ 本件**不挂 item_model**（外观未做或只是未验收的候选模型）。
#   要接的话先补 items/sweetdream:anchor.json + models/ + 贴图，再来这里放行。
# ============================================================
give @s diamond_axe[item_name={text:"沉锚",bold:true,color:blue},lore=[{"text":"✦ 被动技能","color":"gold","bold":true,"italic":false},{"text":"每次攻击时都有 10% 的概率将自身前方 1","color":"gray","italic":false},{"text":"格内的生物击飞 1 格并对其造成相当于自","color":"gray","italic":false},{"text":"身最大魔力值 ×0.06 的伤害。","color":"gray","italic":false},{"text":" ","italic":false},{"text":"✦ 主动技能","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"魔力 ","color":"gray"},{"text":"200","color":"aqua"},{"text":"   ·   ","color":"dark_gray"},{"text":"冷却 ","color":"gray"},{"text":"12 秒","color":"yellow"}]},{"text":" ","italic":false},{"text":"向自身 10 格内的准星上的目标掷出沉锚","color":"gray","italic":false},{"text":"并位移到目标位置，之后对其 2 格内的生","color":"gray","italic":false},{"text":"物造成相当于释放者基础攻击力 ×5 的伤","color":"gray","italic":false},{"text":"害并击飞 2 格。","color":"gray","italic":false}],unbreakable={},custom_data={zx:["anchor","axe","itemreplace"],skill:"sweetdream:anchor",tags:["max_mana","base_atk","dash"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"},tooltip_display={hidden_components:["unbreakable"]}]
