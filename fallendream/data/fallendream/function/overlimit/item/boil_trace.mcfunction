# ============================================================
# fallendream:overlimit/item/boil_trace —— 给一块「超限·沸痕」
# 【接线】custom_data zx:["ol_boil_trace"] 供 advancement 识别；
#   CMD=105 与 _gen_stone_icons.py 的 CMD 表、recovery_compass.json 路由三处一致。
# 【敲入】副手持对应装备 + 主手右键本石 -> consume_item -> apply/boil_trace。
#   三件套(item/advancement/apply)与 oldef 均已就位，敲失败退材料。
# ============================================================

give @s recovery_compass[max_stack_size=1,item_name={text:"超限·沸痕",bold:true,color:light_purple},custom_model_data={floats:[105.0f]},lore=[{"text":"✦ 超限石","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"适用于 ","color":"gray"},{"text":"沸痕","color":"blue"},{"text":"   ·   ","color":"dark_gray"},{"text":"前置 ","color":"gray"},{"text":"尚未超限","color":"aqua"}]},{"text":" ","italic":false},{"text":"敲入后沸痕更名为「超限·沸痕」，自身魔","color":"gray","italic":false},{"text":"力值上限 +180，最大生命值 +8 且额外","color":"gray","italic":false},{"text":"+10 %。自身实际受到火焰或燃烧伤害后，","color":"gray","italic":false},{"text":"若 4 格内有未附有「流火」的生物，则使","color":"gray","italic":false},{"text":"最近一个生物附加「流火」并为自身恢复","color":"gray","italic":false},{"text":"15% 生命值，之后熄灭自身身上的火焰并","color":"gray","italic":false},{"text":"获得 4 秒抗火，期间自身第一次以技能伤","color":"gray","italic":false},{"text":"害命中生物时，为其附加「流火」；若其","color":"gray","italic":false},{"text":"原本已有「流火」而未附有「夜火」，则","color":"gray","italic":false},{"text":"将「流火」转化为「夜火」。该效果 6 秒","color":"gray","italic":false},{"text":"内最多触发一次。","color":"gray","italic":false}],custom_data={zx:["ol_boil_trace"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"}]
