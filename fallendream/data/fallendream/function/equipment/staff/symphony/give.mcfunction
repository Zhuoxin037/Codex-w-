# ============================================================
# fallendream:equipment/staff/symphony/give —— 给一件「交响」（法杖）
# ------------------------------------------------------------
# 【custom_data】
#   "symphony" -> 装备 id, 进度 / 判定靠它认人
#   ★ 判定一律写成 custom_data~{zx:["symphony"]}(部分匹配 + 独有标记)
#   ★ 语义标签 = custom_data.tags(批 A; 词表/逐件表见 .workbuddy/_tags_data.py)
# 【数值】普攻 魔力 100 / 伤害 最大魔力值 ×0.01; 主动 魔力 350 / 冷却 80 秒。
# 【演奏判定】每 2 秒进一拍共 8 拍, 误差以"进拍时刻"为基准(用户 11-18 定):
#   前后 0.2 秒=精准, 0.5 秒=良好, 超过=失败。连续 3 精准起倍率 +10%/半径 +1 格;
#   成功精准 >=6 则下一次最大魔力值技能倍率 +20%。(技能函数后续批次接)
# 【来源】用户 2026-11-18 定稿(删重名版), 文案逐字照抄, 仅按 fallendream-lore 排版。
# 【只做 give】技能 / 进度 / 外观后续批次再接, skill 指向待建函数。
# ★ item_name 主题色 light_purple = 暂定, 待用户点头(与稀有度无关)。
# ★ 本件不挂 item_model(外观未做)。法杖统一 max_stack_size=1。
#   有模型后再补 items/symphony.json + models/ + 贴图, 并配 custom_model_data。
# ============================================================
give @s recovery_compass[max_stack_size=1,item_name={text:"交响",bold:true,color:light_purple},lore=[{"text":"秘器 · 法杖 · 通用","color":"gold","bold":true,"italic":false},{"text":" ","italic":false},{"text":"✦ 普攻","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"魔力 ","color":"gray"},{"text":"100","color":"aqua"},{"text":"   ·   ","color":"dark_gray"},{"text":"伤害 ","color":"gray"},{"text":"最大魔力值 ×0.01","color":"yellow"}]},{"text":" ","italic":false},{"text":"普攻命中生物后额外对其 1 格内的生物造","color":"gray","italic":false},{"text":"成一次相当于自身最大魔力值 ×0.03 的固","color":"gray","italic":false},{"text":"定伤害。","color":"gray","italic":false},{"text":" ","italic":false},{"text":"✦ 主动技能","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"魔力 ","color":"gray"},{"text":"350","color":"aqua"},{"text":"   ·   ","color":"dark_gray"},{"text":"冷却 ","color":"gray"},{"text":"80 秒","color":"yellow"}]},{"text":" ","italic":false},{"text":"使用后每 2 秒进一拍，技能期间总共进 8","color":"gray","italic":false},{"text":"拍。若自身在进拍时使用普攻则视为演奏。","color":"gray","italic":false},{"text":"● 精准：演奏误差前后 0.2 秒内，本次","color":"gray","italic":false},{"text":"   普攻伤害提升为相当于自身最大魔力值","color":"gray","italic":false},{"text":"   ×0.08 的伤害且不会消耗技能倍率。","color":"gray","italic":false},{"text":"● 良好：演奏误差前后 0.5 秒内，本次","color":"gray","italic":false},{"text":"   普攻伤害提升为相当于自身最大魔力值","color":"gray","italic":false},{"text":"   ×0.06 的固定伤害。","color":"gray","italic":false},{"text":"● 失败：演奏误差超过 0.5 秒，本次伤","color":"gray","italic":false},{"text":"   害为原普攻伤害。","color":"gray","italic":false},{"text":" ","italic":false},{"text":"若连续 3 次及以上精准，则从第 3 次精","color":"gray","italic":false},{"text":"准开始伤害倍率提高 10%，且范围半径扩","color":"gray","italic":false},{"text":"大 1 格。则技能结束后若本次成功精准 6","color":"gray","italic":false},{"text":"次及以上，则自身下一次最大魔力值技能","color":"gray","italic":false},{"text":"倍率 +20%。","color":"gray","italic":false}],unbreakable={},custom_data={zx:["symphony","staff","itemreplace"],rarity:"t4",skill:"fallendream:symphony",tags:["max_mana","flat","buff"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"},tooltip_display={hidden_components:["unbreakable"]}]
