# ============================================================
# sweetdream:equipment/axe/frost_carve/give —— 给一件「剜霜」（史诗 · 斧）
# ------------------------------------------------------------
# 【custom_data】
#   "frost_carve" -> 装备 id, 进度 / 被动判定靠它认人
#   ★ 判定一律写成 custom_data~{zx:["frost_carve"]}(部分匹配 + 独有标记)
#   ★ 语义标签 = custom_data.tags(批 A; 词表/逐件表见 .workbuddy/_tags_data.py)
# 【描述构成】✦ 主动技能
# 【底材】diamond_axe（史诗 = diamond）
#
# 【这个文件是生成的】改描述请改 .workbuddy/_new42_lore.py、改标签请改
#   .workbuddy/_tags_data.py，然后重跑本生成器 + `python .workbuddy/lore_fmt.py --write`。
# 【外观】批 16（2026-10-18）补齐：item_model 指向 sweetdream:frost_carve
#   （贴图源 _gen_late_icons.py，接线 _gen_late_rp.py）。
# ============================================================
give @s diamond_axe[item_name={text:"剜霜",bold:true,color:aqua},lore=[{"text":"✦ 主动技能","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"魔力 ","color":"gray"},{"text":"200","color":"aqua"},{"text":"   ·   ","color":"dark_gray"},{"text":"冷却 ","color":"gray"},{"text":"30 秒","color":"yellow"}]},{"text":" ","italic":false},{"text":"使用后重击前方 4×3 格范围内的生物，造","color":"gray","italic":false},{"text":"成一次相当于自身基础攻击力 ×5 的伤害，","color":"gray","italic":false},{"text":"之后使未处于冰冻状态的生物被冰冻 1 秒，","color":"gray","italic":false},{"text":"已处于冰冻状态的生物解除冰冻，并额外","color":"gray","italic":false},{"text":"受到一次相当于自身基础攻击力 ×2 的伤","color":"gray","italic":false},{"text":"害。若本次至少解除了两个生物的冰冻，","color":"gray","italic":false},{"text":"则为自身恢复最大生命值 10% 的生命。","color":"gray","italic":false}],unbreakable={},custom_data={zx:["frost_carve","axe","itemreplace"],skill:"sweetdream:frost_carve",tags:["max_hp","base_atk","freeze","debuff","heal","consume"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"},tooltip_display={hidden_components:["unbreakable"]},item_model="sweetdream:frost_carve"]
