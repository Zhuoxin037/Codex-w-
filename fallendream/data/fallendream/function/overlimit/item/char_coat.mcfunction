# ============================================================
# fallendream:overlimit/item/char_coat —— 给一块「超限·焦衣」
# 【接线】custom_data zx:["ol_char_coat"] 供 advancement 识别；
#   CMD=130 与 _gen_stone_icons.py 的 CMD 表、recovery_compass.json 路由三处一致。
# 【敲入】副手持对应装备 + 主手右键本石 -> consume_item -> apply/char_coat。
#   三件套(item/advancement/apply)与 oldef 均已就位，敲失败退材料。
# ============================================================

give @s recovery_compass[max_stack_size=1,item_name={text:"超限·焦衣",bold:true,color:light_purple},custom_model_data={floats:[130.0f]},lore=[{"text":"✦ 超限石","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"适用于 ","color":"gray"},{"text":"焦衣","color":"blue"},{"text":"   ·   ","color":"dark_gray"},{"text":"前置 ","color":"gray"},{"text":"尚未超限","color":"aqua"}]},{"text":" ","italic":false},{"text":"敲入后焦衣更名为「超限·焦衣」，自身魔","color":"gray","italic":false},{"text":"力值上限 +180。自身主动技能的普通伤害","color":"gray","italic":false},{"text":"命中了附有「流火」而未附有「夜火」的","color":"gray","italic":false},{"text":"生物后，若魔力足够，则消耗 50 魔力，","color":"gray","italic":false},{"text":"将其「流火」转化为「夜火」，之后偷取","color":"gray","italic":false},{"text":"生效生物的 20% 基础攻击力并加在自身上，","color":"gray","italic":false},{"text":"持续 8 秒。该效果 10 秒内最多触发一次。","color":"gray","italic":false},{"text":"自身攻击被偷取了任意属性的生物时都会","color":"gray","italic":false},{"text":"使其额外受到一次相当于自身基础攻击力","color":"gray","italic":false},{"text":"的伤害。","color":"gray","italic":false}],custom_data={zx:["ol_char_coat"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"}]
