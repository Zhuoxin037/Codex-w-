# ============================================================
# fallendream:overlimit/item/ember_string —— 给一块「超限·烬弦」
# 【接线】custom_data zx:["ol_ember_string"] 供 advancement 识别；
#   CMD=98 与 _gen_stone_icons.py 的 CMD 表、recovery_compass.json 路由三处一致。
# 【敲入】副手持对应装备 + 主手右键本石 -> consume_item -> apply/ember_string。
#   三件套(item/advancement/apply)与 oldef 均已就位，敲失败退材料。
# ============================================================

give @s recovery_compass[max_stack_size=1,item_name={text:"超限·烬弦",bold:true,color:light_purple},custom_model_data={floats:[98.0f]},lore=[{"text":"✦ 超限石","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"适用于 ","color":"gray"},{"text":"烬弦","color":"blue"},{"text":"   ·   ","color":"dark_gray"},{"text":"前置 ","color":"gray"},{"text":"尚未超限","color":"aqua"}]},{"text":" ","italic":false},{"text":"敲入后烬弦更名为「超限·烬弦」，主动技","color":"gray","italic":false},{"text":"能变为：魔力 100 每次射击命中生物后，","color":"gray","italic":false},{"text":"若其既未附有「流火」和「夜火」，则使","color":"gray","italic":false},{"text":"其附加「流火」。若其附有「流火」且未","color":"gray","italic":false},{"text":"附有「夜火」，则将其「流火」转化为","color":"gray","italic":false},{"text":"「夜火」。若其已附有「夜火」，则改为","color":"gray","italic":false},{"text":"额外造成一次相当于自身最大魔力值","color":"gray","italic":false},{"text":"×0.06 的伤害。以上三个效果每个对生物","color":"gray","italic":false},{"text":"4 秒最多触发一次。若对一个生物在 12","color":"gray","italic":false},{"text":"秒内触发了以上全部效果，则对其造成一","color":"gray","italic":false},{"text":"次相当于自身最大魔力值 x 0.08 的伤害","color":"gray","italic":false},{"text":"并使其随机附加一个除了「流火」和","color":"gray","italic":false},{"text":"「夜火」的标签。","color":"gray","italic":false}],custom_data={zx:["ol_ember_string"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"}]
