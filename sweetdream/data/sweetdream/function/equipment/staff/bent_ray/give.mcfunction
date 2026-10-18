# ============================================================
# sweetdream:equipment/staff/bent_ray/give —— 给一件「折径」（史诗 · 法杖）
# ------------------------------------------------------------
# 【custom_data】
#   "bent_ray" -> 装备 id, 进度 / 被动判定靠它认人
#   ★ 判定一律写成 custom_data~{zx:["bent_ray"]}(部分匹配 + 独有标记)
#   ★ 语义标签 = custom_data.tags(批 A; 词表/逐件表见 .workbuddy/_tags_data.py)
# 【描述构成】✦ 普攻 ｜ ✦ 主动技能
# 【底材】recovery_compass（史诗 = diamond）
#
# 【这个文件是生成的】改描述请改 .workbuddy/_new42_lore.py、改标签请改
#   .workbuddy/_tags_data.py，然后重跑本生成器 + `python .workbuddy/lore_fmt.py --write`。
# 【外观】批 16（2026-10-18）补齐：item_model 指向 sweetdream:bent_ray
#   （贴图源 _gen_late_icons.py，接线 _gen_late_rp.py）。
# ============================================================
give @s recovery_compass[max_stack_size=1,item_name={text:"折径",bold:true,color:light_purple},lore=[{"text":"✦ 普攻","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"魔力 ","color":"gray"},{"text":"60","color":"aqua"},{"text":"   ·   ","color":"dark_gray"},{"text":"伤害 ","color":"gray"},{"text":"8","color":"yellow"}]},{"text":" ","italic":false},{"text":"每次普攻命中后使其附加「折光」。","color":"gray","italic":false},{"text":" ","italic":false},{"text":"✦ 主动技能","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"魔力 ","color":"gray"},{"text":"250","color":"aqua"},{"text":"   ·   ","color":"dark_gray"},{"text":"冷却 ","color":"gray"},{"text":"30 秒","color":"yellow"}]},{"text":" ","italic":false},{"text":"使用后对自身 8 格内最近的生物发射光束，","color":"gray","italic":false},{"text":"并对其造成一次相当于自身最大魔力值","color":"gray","italic":false},{"text":"×0.04+8 的伤害。若其 5 格内有附有","color":"gray","italic":false},{"text":"「折光」的生物，则光束继续射向其最近","color":"gray","italic":false},{"text":"的附有「折光」的生物并消除其「折光」，","color":"gray","italic":false},{"text":"每次射出都会使本次伤害提高 20%（独立","color":"gray","italic":false},{"text":"乘区，不包含固定伤害）。以上最多重复","color":"gray","italic":false},{"text":"6 次。","color":"gray","italic":false}],unbreakable={},custom_data={zx:["bent_ray","staff","itemreplace"],skill:"sweetdream:bent_ray",tags:["max_mana","flat","indep_mul","apply","consume"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"},tooltip_display={hidden_components:["unbreakable"]},item_model="sweetdream:bent_ray"]
