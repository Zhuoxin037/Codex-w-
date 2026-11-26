# ============================================================
# fallendream:overlimit/item/flint_hat —— 给一块「超限·燧帽」
# 【接线】custom_data zx:["ol_flint_hat"] 供 advancement 识别；
#   CMD=99 与 _gen_stone_icons.py 的 CMD 表、recovery_compass.json 路由三处一致。
# 【敲入】副手持对应装备 + 主手右键本石 -> consume_item -> apply/flint_hat。
#   三件套(item/advancement/apply)与 oldef 均已就位，敲失败退材料。
# ============================================================

give @s recovery_compass[max_stack_size=1,item_name={text:"超限·燧帽",bold:true,color:light_purple},custom_model_data={floats:[99.0f]},lore=[{"text":"✦ 超限石","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"适用于 ","color":"gray"},{"text":"燧帽","color":"blue"},{"text":"   ·   ","color":"dark_gray"},{"text":"前置 ","color":"gray"},{"text":"尚未超限","color":"aqua"}]},{"text":" ","italic":false},{"text":"敲入后燧帽更名为「超限·燧帽」，自身魔","color":"gray","italic":false},{"text":"力值上限 +120。普通近战命中了未附有","color":"gray","italic":false},{"text":"「流火」且仍存活的生物后，若魔力足够，","color":"gray","italic":false},{"text":"则消耗 15 魔力并使其附加「流火」。该","color":"gray","italic":false},{"text":"效果 6 秒内最多触发一次。自身成功消费","color":"gray","italic":false},{"text":"「流火」后，该效果冷却立刻结束，且下","color":"gray","italic":false},{"text":"一次触发时，本次附加的「流火」改为使","color":"gray","italic":false},{"text":"其基础护甲值降低 50%。本次仍消耗 15","color":"gray","italic":false},{"text":"魔力并保留 6 秒触发间隔，强化持续至本","color":"gray","italic":false},{"text":"次「流火」结束或被顶替。","color":"gray","italic":false}],custom_data={zx:["ol_flint_hat"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"}]
