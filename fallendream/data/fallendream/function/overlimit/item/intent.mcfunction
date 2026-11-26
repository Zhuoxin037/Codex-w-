# ============================================================
# fallendream:overlimit/item/intent —— 给一块「超限·蓄意」
# 【接线】custom_data zx:["ol_intent"] 供 advancement 识别；
#   CMD=90 与 _gen_stone_icons.py 的 CMD 表、recovery_compass.json 路由三处一致。
# 【敲入】副手持对应装备 + 主手右键本石 -> consume_item -> apply/intent。
#   三件套(item/advancement/apply)与 oldef 均已就位，敲失败退材料。
# ============================================================

give @s recovery_compass[max_stack_size=1,item_name={text:"超限·蓄意",bold:true,color:light_purple},custom_model_data={floats:[90.0f]},lore=[{"text":"✦ 超限石","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"适用于 ","color":"gray"},{"text":"蓄意","color":"blue"},{"text":"   ·   ","color":"dark_gray"},{"text":"前置 ","color":"gray"},{"text":"尚未超限","color":"aqua"}]},{"text":" ","italic":false},{"text":"敲入后蓄意更名为「超限·蓄意」，自身魔","color":"gray","italic":false},{"text":"力值上限 + 200 ，最大生命值 + 30 %。","color":"gray","italic":false},{"text":"自身每使用 50 魔力值则自身获得 2 点临","color":"gray","italic":false},{"text":"时生命值（单技能可重复触发）。当自身","color":"gray","italic":false},{"text":"的临时生命值清空后自身获得 7 秒抗性提","color":"gray","italic":false},{"text":"升Ⅱ和迅捷Ⅲ，该效果持续期间若再次触","color":"gray","italic":false},{"text":"发则自身额外获得 10 秒抗性提升 4 和最","color":"gray","italic":false},{"text":"大生命值 + 10 %，若此期间再次触发则该","color":"gray","italic":false},{"text":"效果重置为 10 秒。","color":"gray","italic":false}],custom_data={zx:["ol_intent"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"}]
