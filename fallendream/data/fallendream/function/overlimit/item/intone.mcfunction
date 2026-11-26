# ============================================================
# fallendream:overlimit/item/intone —— 给一块「超限·引声」
# 【接线】custom_data zx:["ol_intone"] 供 advancement 识别；
#   CMD=115 与 _gen_stone_icons.py 的 CMD 表、recovery_compass.json 路由三处一致。
# 【敲入】副手持对应装备 + 主手右键本石 -> consume_item -> apply/intone。
#   三件套(item/advancement/apply)与 oldef 均已就位，敲失败退材料。
# ============================================================

give @s recovery_compass[max_stack_size=1,item_name={text:"超限·引声",bold:true,color:light_purple},custom_model_data={floats:[115.0f]},lore=[{"text":"✦ 超限石","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"适用于 ","color":"gray"},{"text":"引声","color":"blue"},{"text":"   ·   ","color":"dark_gray"},{"text":"前置 ","color":"gray"},{"text":"尚未超限","color":"aqua"}]},{"text":" ","italic":false},{"text":"敲入后引声更名为「超限·引声」，普攻变","color":"gray","italic":false},{"text":"为：魔力 20 · 伤害 最大魔力值 ×0.01","color":"gray","italic":false},{"text":"主动技能变为：魔力 160 · 冷却 15 秒使","color":"gray","italic":false},{"text":"用后使自身全部“追随者”触发一次被动。","color":"gray","italic":false},{"text":"若自身已醒梦，则额外触发一次合奏（不","color":"gray","italic":false},{"text":"受上限与冷却限制）。 1 秒后，使自身全","color":"gray","italic":false},{"text":"部“追随者”再次触发一次被动并刷新其","color":"gray","italic":false},{"text":"持续时间。若本次对生物造成了伤害则使","color":"gray","italic":false},{"text":"其附加「渊海」。","color":"gray","italic":false}],custom_data={zx:["ol_intone"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"}]
