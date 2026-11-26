# ============================================================
# fallendream:overlimit/item/spirit_sight —— 给一块「超限·灵视」
# 【接线】custom_data zx:["ol_spirit_sight"] 供 advancement 识别；
#   CMD=93 与 _gen_stone_icons.py 的 CMD 表、recovery_compass.json 路由三处一致。
# 【敲入】副手持对应装备 + 主手右键本石 -> consume_item -> apply/spirit_sight。
#   三件套(item/advancement/apply)与 oldef 均已就位，敲失败退材料。
# ============================================================

give @s recovery_compass[max_stack_size=1,item_name={text:"超限·灵视",bold:true,color:light_purple},custom_model_data={floats:[93.0f]},lore=[{"text":"✦ 超限石","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"适用于 ","color":"gray"},{"text":"灵视","color":"blue"},{"text":"   ·   ","color":"dark_gray"},{"text":"前置 ","color":"gray"},{"text":"尚未超限","color":"aqua"}]},{"text":" ","italic":false},{"text":"敲入后灵视更名为「超限·灵视」，自身魔","color":"gray","italic":false},{"text":"力值上限＋140。自身 8 格内若有带有","color":"gray","italic":false},{"text":"「渊海」、「流火」、「夜火」、","color":"gray","italic":false},{"text":"「白昼梦」、「噬心」任一标签的生物则","color":"gray","italic":false},{"text":"使其发光并使其获得缓慢Ⅱ效果，且其受","color":"gray","italic":false},{"text":"到的最大魔力值相关的技能伤害 + 24% ，","color":"gray","italic":false},{"text":"其护甲值及护甲韧性也会－ 20% ，每有一","color":"gray","italic":false},{"text":"个则自身每秒恢复 8 魔力值。","color":"gray","italic":false}],custom_data={zx:["ol_spirit_sight"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"}]
