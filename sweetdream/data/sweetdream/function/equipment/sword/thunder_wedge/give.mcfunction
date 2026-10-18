# ============================================================
# sweetdream:equipment/sword/thunder_wedge/give —— 给一件「雷楔」（史诗 · 剑）
# ------------------------------------------------------------
# 【custom_data】
#   "thunder_wedge" -> 装备 id, 进度 / 被动判定靠它认人
#   ★ 判定一律写成 custom_data~{zx:["thunder_wedge"]}(部分匹配 + 独有标记)
#   ★ 语义标签 = custom_data.tags(批 A; 词表/逐件表见 .workbuddy/_tags_data.py)
# 【描述构成】✦ 主动技能 ｜ ✦ 雷楔
# 【底材】diamond_sword（史诗 = diamond）
#
# 【这个文件是生成的】改描述请改 .workbuddy/_new42_lore.py、改标签请改
#   .workbuddy/_tags_data.py，然后重跑本生成器 + `python .workbuddy/lore_fmt.py --write`。
# 【外观】批 16（2026-10-18）补齐：item_model 指向 sweetdream:thunder_wedge
#   （贴图源 _gen_late_icons.py，接线 _gen_late_rp.py）。
# ============================================================
give @s diamond_sword[item_name={text:"雷楔",bold:true,color:yellow},lore=[{"text":"✦ 主动技能","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"魔力 ","color":"gray"},{"text":"300","color":"aqua"},{"text":"   ·   ","color":"dark_gray"},{"text":"冷却 ","color":"gray"},{"text":"60 秒","color":"yellow"}]},{"text":" ","italic":false},{"text":"使用后召唤 1 个术阵，并在自身位置召唤","color":"gray","italic":false},{"text":"一个持续 8 秒的“雷楔”。同一使用者同","color":"gray","italic":false},{"text":"时只能存在一个。","color":"gray","italic":false},{"text":" ","italic":false},{"text":"✦ 雷楔","color":"gold","bold":true,"italic":false},{"text":"使用者攻击了“雷楔”8 格内的生物后，","color":"gray","italic":false},{"text":"“雷楔”对命中位置释放一次闪电，对其","color":"gray","italic":false},{"text":"1 格内的生物造成一次相当于使用者基础","color":"gray","italic":false},{"text":"攻击力 ×2 的伤害，每秒最多触发一次。","color":"gray","italic":false}],unbreakable={},custom_data={zx:["thunder_wedge","sword","itemreplace"],skill:"sweetdream:thunder_wedge",tags:["lightning","base_atk","summon","formation"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"},tooltip_display={hidden_components:["unbreakable"]},item_model="sweetdream:thunder_wedge"]
