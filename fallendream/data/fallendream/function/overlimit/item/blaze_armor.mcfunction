# ============================================================
# fallendream:overlimit/item/blaze_armor —— 给一块「超限·焱」
# 【接线】custom_data zx:["ol_blaze_armor"] 供 advancement 识别；
#   CMD=127 与 _gen_stone_icons.py 的 CMD 表、recovery_compass.json 路由三处一致。
# 【敲入】副手持对应装备 + 主手右键本石 -> consume_item -> apply/blaze_armor。
#   三件套(item/advancement/apply)与 oldef 均已就位，敲失败退材料。
# ============================================================

give @s recovery_compass[max_stack_size=1,item_name={text:"超限·焱",bold:true,color:light_purple},custom_model_data={floats:[127.0f]},lore=[{"text":"✦ 超限石","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"适用于 ","color":"gray"},{"text":"焱","color":"blue"},{"text":"   ·   ","color":"dark_gray"},{"text":"前置 ","color":"gray"},{"text":"尚未超限","color":"aqua"}]},{"text":" ","italic":false},{"text":"敲入后焱更名为「超限·焱」，获得常态的","color":"gray","italic":false},{"text":"抗火效果，且视为金甲。自身魔力值上限","color":"gray","italic":false},{"text":"+180。攻击自身的生物若未处于燃烧状态，","color":"gray","italic":false},{"text":"则使其获得 5 秒的燃烧状态并使其获得","color":"gray","italic":false},{"text":"「流火」效果。若其已处于燃烧状态则自","color":"gray","italic":false},{"text":"身获得再生Ⅱ效果及力量Ⅲ效果，持续 5","color":"gray","italic":false},{"text":"秒，之后使其 3 格内的 2 个其他未附有","color":"gray","italic":false},{"text":"「流火」的生物获得 5 秒的燃烧状态并使","color":"gray","italic":false},{"text":"其获得「流火」效果。自身的下一次普通","color":"gray","italic":false},{"text":"近战也将使受到伤害的生物获得 3 秒燃烧","color":"gray","italic":false},{"text":"状态并使其受到一次相当于自身基础攻击","color":"gray","italic":false},{"text":"力的固定伤害。","color":"gray","italic":false}],custom_data={zx:["ol_blaze_armor"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"}]
