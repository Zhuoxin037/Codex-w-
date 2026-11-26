# ============================================================
# fallendream:overlimit/item/bearing —— 给一块「超限·承」
# 【接线】custom_data zx:["ol_bearing"] 供 advancement 识别；
#   CMD=124 与 _gen_stone_icons.py 的 CMD 表、recovery_compass.json 路由三处一致。
# 【敲入】副手持对应装备 + 主手右键本石 -> consume_item -> apply/bearing。
#   三件套(item/advancement/apply)与 oldef 均已就位，敲失败退材料。
# ============================================================

give @s recovery_compass[max_stack_size=1,item_name={text:"超限·承",bold:true,color:light_purple},custom_model_data={floats:[124.0f]},lore=[{"text":"✦ 超限石","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"适用于 ","color":"gray"},{"text":"承","color":"blue"},{"text":"   ·   ","color":"dark_gray"},{"text":"前置 ","color":"gray"},{"text":"尚未超限","color":"aqua"}]},{"text":" ","italic":false},{"text":"敲入后承更名为「超限·承」，自身魔力值","color":"gray","italic":false},{"text":"上限 +180。每占用 1 个术阵位，自身护","color":"gray","italic":false},{"text":"甲值 +2 、护甲韧性 +1 。自身术阵为空","color":"gray","italic":false},{"text":"时，移动速度 +8% 。术阵结束时自身恢复","color":"gray","italic":false},{"text":"1% 魔力值，且自身的护甲值和护甲韧性加","color":"gray","italic":false},{"text":"成会额外保留 4 秒。自身保持满术阵 4","color":"gray","italic":false},{"text":"秒后，进入「阵成」，持续 8 秒（可以和","color":"gray","italic":false},{"text":"套装及枢的「阵成」加算叠加），冷却 12","color":"gray","italic":false},{"text":"秒。套装的「阵成」所需的术阵数 -1 。","color":"gray","italic":false}],custom_data={zx:["ol_bearing"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"}]
