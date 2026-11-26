# ============================================================
# fallendream:overlimit/item/air_step —— 给一块「超限·踏空」
# 【接线】custom_data zx:["ol_air_step"] 供 advancement 识别；
#   CMD=91 与 _gen_stone_icons.py 的 CMD 表、recovery_compass.json 路由三处一致。
# 【敲入】副手持对应装备 + 主手右键本石 -> consume_item -> apply/air_step。
#   三件套(item/advancement/apply)与 oldef 均已就位，敲失败退材料。
# ============================================================

give @s recovery_compass[max_stack_size=1,item_name={text:"超限·踏空",bold:true,color:light_purple},custom_model_data={floats:[91.0f]},lore=[{"text":"✦ 超限石","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"适用于 ","color":"gray"},{"text":"踏空","color":"blue"},{"text":"   ·   ","color":"dark_gray"},{"text":"前置 ","color":"gray"},{"text":"尚未超限","color":"aqua"}]},{"text":" ","italic":false},{"text":"敲入后踏空更名为「超限·踏空」，自身魔","color":"gray","italic":false},{"text":"力值上限 + 140。自身从空中落地时生成","color":"gray","italic":false},{"text":"一个半径 4 格，持续 5 秒的领域。在领","color":"gray","italic":false},{"text":"域内的生物每秒都会受到一次相当于释放","color":"gray","italic":false},{"text":"者基础攻击力的伤害并被击飞 1 格并获得","color":"gray","italic":false},{"text":"2 秒缓慢Ⅰ。每有一个生物受到影响则自","color":"gray","italic":false},{"text":"身恢复 10 魔力值。该效果 10 秒最多触","color":"gray","italic":false},{"text":"发一次。","color":"gray","italic":false}],custom_data={zx:["ol_air_step"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"}]
