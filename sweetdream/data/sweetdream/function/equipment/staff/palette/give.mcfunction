# ============================================================
# sweetdream:equipment/staff/palette/give —— 给一件「调色盘」（法杖）
# ------------------------------------------------------------
# 【custom_data】
#   "palette" -> 装备 id, 进度 / 被动判定靠它认人
#   ★ 判定一律写成 custom_data~{zx:["palette"]}(部分匹配 + 独有标记)
#   ★ 语义标签 = custom_data.tags(批 A; 词表/逐件表见 .workbuddy/_tags_data.py)
# 【普攻 + 主动】普攻 50 / 伤害 1; 命中后随机攒颜色(可叠, 最多同时两种)。
#   主动 400 / 60 秒 -> 生成“色彩”。
#   “色彩”12 格或打满 5 个后自毁, 自动追最近生物 ×0.1, 不会追已打过的生物。
#   红=伤害翻倍 / 黄=追踪范围 +8、阈值 +3 / 蓝=打中后回 150 魔力并 -5 秒冷却。
# 【X 种颜色 = 最多 2 种】实装时按实际持有色数乘算。
#
# 【这个文件是生成的】改描述/数值请改 .workbuddy/_gen_batch6.py 再重跑,
#   然后跑 `python .workbuddy/lore_fmt.py --write` 让规范器重新折行。
# ============================================================
give @s recovery_compass[max_stack_size=1,item_model="palette:palette",custom_model_data={floats:[0.0f,0.0f,0.0f,0.0f,1.0f]},item_name={text:"调色盘",bold:true,color:light_purple},lore=[{"text":"✦ 普攻","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"魔力 ","color":"gray"},{"text":"50","color":"aqua"},{"text":"   ·   ","color":"dark_gray"},{"text":"伤害 ","color":"gray"},{"text":"1","color":"yellow"}]},{"text":" ","italic":false},{"text":"每次普攻命中后都会随机积攒一种颜色。","color":"gray","italic":false},{"text":"颜色可以叠加，最多同时持有两种颜色。","color":"gray","italic":false},{"text":" ","italic":false},{"text":"✦ 主动技能","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"魔力 ","color":"gray"},{"text":"400","color":"aqua"},{"text":"   ·   ","color":"dark_gray"},{"text":"冷却 ","color":"gray"},{"text":"60 秒","color":"yellow"}]},{"text":" ","italic":false},{"text":"使用后将生成一个“色彩”。","color":"gray","italic":false},{"text":" ","italic":false},{"text":"✦ 色彩","color":"gold","bold":true,"italic":false},{"text":"“色彩”会离自身 12 格远或对 5 个生物","color":"gray","italic":false},{"text":"造成伤害后自毁。“色彩”会自动追踪离","color":"gray","italic":false},{"text":"自身最近的生物并对其造成相当于自身最","color":"gray","italic":false},{"text":"大魔力值 ×0.1 的伤害。若调色盘上有颜","color":"gray","italic":false},{"text":"色则强化效果。“色彩”不会追踪已经攻","color":"gray","italic":false},{"text":"击过的生物。","color":"gray","italic":false},{"text":" ","italic":false},{"text":"● 红：每有一个红色都会将伤害提高 1","color":"gray","italic":false},{"text":"   倍。","color":"gray","italic":false},{"text":"● 黄：每有一个黄色都会将“色彩”的追","color":"gray","italic":false},{"text":"   踪范围扩大 8 格，并将可追踪生物的","color":"gray","italic":false},{"text":"   阀值提高 3 个。","color":"gray","italic":false},{"text":"● 蓝：每有一个蓝色则在“色彩”对生物","color":"gray","italic":false},{"text":"   造成伤害后回复自身 150 点魔力值并","color":"gray","italic":false},{"text":"   使技能冷却时间 -5 秒。","color":"gray","italic":false}],unbreakable={},custom_data={zx:["palette","staff","itemreplace"],skill:"sweetdream:palette",tags:["max_mana","summon","cd_down"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"},tooltip_display={hidden_components:["unbreakable"]}]
