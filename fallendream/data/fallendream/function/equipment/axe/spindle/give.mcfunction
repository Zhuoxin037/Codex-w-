# ============================================================
# fallendream:equipment/axe/spindle/give —— 给一件「旋梭」（斧）
# ------------------------------------------------------------
# 【custom_data】
#   "spindle" -> 装备 id, 进度 / 被动判定靠它认人
#   ★ 判定一律写成 custom_data~{zx:["spindle"]}(部分匹配 + 独有标记)
#   ★ 语义标签 = custom_data.tags(批 A; 词表/逐件表见 .workbuddy/_tags_data.py)
# 【数值】主动: 魔力 200 / 冷却 40 秒, 三段路径(去/停/回) + 累计 3 次附「噬心」。
# 【来源】用户 2026-11-18 定稿(删重名版), 文案逐字照抄, 仅按 fallendream-lore 排版。
# 【只做 give】技能 / 进度 / 外观后续批次再接(沉锚先例), skill 指向待建函数。
# ★ item_name 主题色 gold = 暂定, 待用户点头(与稀有度无关)。
# ★ 本件不挂 item_model(外观未做)。要接先补 items/models/贴图再放行。
# ============================================================
give @s diamond_axe[item_name={text:"旋梭",bold:true,color:gold},lore=[{"text":"精器 · 斧 · 通用","color":"aqua","bold":true,"italic":false},{"text":" ","italic":false},{"text":"✦ 主动技能","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"魔力 ","color":"gray"},{"text":"200","color":"aqua"},{"text":"   ·   ","color":"dark_gray"},{"text":"冷却 ","color":"gray"},{"text":"40 秒","color":"yellow"}]},{"text":" ","italic":false},{"text":"使用后向前投掷该武器 8 格。在路径上的","color":"gray","italic":false},{"text":"生物会受到一次相当于释放者基础攻击力","color":"gray","italic":false},{"text":"×2 的伤害并被击退一格。到达尽头后会在","color":"gray","italic":false},{"text":"尽头处停留 2 秒，期间对尽头处的生物每","color":"gray","italic":false},{"text":"5 刻造成一次相当于释放者基础攻击力的","color":"gray","italic":false},{"text":"伤害。之后向自身收回，在路径上的生物","color":"gray","italic":false},{"text":"会受到一次相当于释放者基础攻击力 ×2","color":"gray","italic":false},{"text":"的伤害并被拉向释放者一格。之后共受到","color":"gray","italic":false},{"text":"本武器 3 次以上的伤害的生物附加","color":"gray","italic":false},{"text":"「噬心」。","color":"gray","italic":false}],unbreakable={},custom_data={zx:["spindle","axe","itemreplace"],rarity:"t3",skill:"fallendream:spindle",tags:["shixin","base_atk","attract"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"},tooltip_display={hidden_components:["unbreakable"]}]
