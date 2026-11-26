# ============================================================
# fallendream:overlimit/item/tide_watch —— 给一块「超限·候潮」
# 【接线】custom_data zx:["ol_tide_watch"] 供 advancement 识别；
#   CMD=103 与 _gen_stone_icons.py 的 CMD 表、recovery_compass.json 路由三处一致。
# 【敲入】副手持对应装备 + 主手右键本石 -> consume_item -> apply/tide_watch。
#   三件套(item/advancement/apply)与 oldef 均已就位，敲失败退材料。
# ============================================================

give @s recovery_compass[max_stack_size=1,item_name={text:"超限·候潮",bold:true,color:light_purple},custom_model_data={floats:[103.0f]},lore=[{"text":"✦ 超限石","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"适用于 ","color":"gray"},{"text":"候潮","color":"blue"},{"text":"   ·   ","color":"dark_gray"},{"text":"前置 ","color":"gray"},{"text":"尚未超限","color":"aqua"}]},{"text":" ","italic":false},{"text":"敲入后候潮更名为「超限·候潮」，被动技","color":"gray","italic":false},{"text":"能变为：自身魔力值上限 +160。自身主动","color":"gray","italic":false},{"text":"技能命中生物后，若其未附加「渊海」且","color":"gray","italic":false},{"text":"自身魔力足够，则消耗 30 魔力并使其附","color":"gray","italic":false},{"text":"加「渊海」。由本件附加的「渊海」被自","color":"gray","italic":false},{"text":"身消耗后，自身恢复 2% 最大魔力值并获","color":"gray","italic":false},{"text":"得 4 秒抗性提升Ⅱ，之后使自身 3 格内","color":"gray","italic":false},{"text":"的生物被击退一格。","color":"gray","italic":false}],custom_data={zx:["ol_tide_watch"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"}]
