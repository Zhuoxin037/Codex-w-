# ============================================================
# fallendream:overlimit/item/light_pillow —— 给一块「超限·轻枕」
# 【接线】custom_data zx:["ol_light_pillow"] 供 advancement 识别；
#   CMD=100 与 _gen_stone_icons.py 的 CMD 表、recovery_compass.json 路由三处一致。
# 【敲入】副手持对应装备 + 主手右键本石 -> consume_item -> apply/light_pillow。
#   三件套(item/advancement/apply)与 oldef 均已就位，敲失败退材料。
# ============================================================

give @s recovery_compass[max_stack_size=1,item_name={text:"超限·轻枕",bold:true,color:light_purple},custom_model_data={floats:[100.0f]},lore=[{"text":"✦ 超限石","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"适用于 ","color":"gray"},{"text":"轻枕","color":"blue"},{"text":"   ·   ","color":"dark_gray"},{"text":"前置 ","color":"gray"},{"text":"尚未超限","color":"aqua"}]},{"text":" ","italic":false},{"text":"敲入后轻枕更名为「超限·轻枕」，自身魔","color":"gray","italic":false},{"text":"力值上限 +120。受到原本附有「白昼梦」","color":"gray","italic":false},{"text":"的生物造成的近战伤害后，获得 5 秒抗性","color":"gray","italic":false},{"text":"提升Ⅲ及迅捷Ⅱ，之后使攻击自身的生物","color":"gray","italic":false},{"text":"时停 1 秒。该效果 3 秒内最多触发一次。","color":"gray","italic":false}],custom_data={zx:["ol_light_pillow"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"}]
