# ============================================================
# fallendream:overlimit/item/pivot —— 给一块「超限·枢」
# 【接线】custom_data zx:["ol_pivot"] 供 advancement 识别；
#   CMD=125 与 _gen_stone_icons.py 的 CMD 表、recovery_compass.json 路由三处一致。
# 【敲入】副手持对应装备 + 主手右键本石 -> consume_item -> apply/pivot。
#   三件套(item/advancement/apply)与 oldef 均已就位，敲失败退材料。
# ============================================================

give @s recovery_compass[max_stack_size=1,item_name={text:"超限·枢",bold:true,color:light_purple},custom_model_data={floats:[125.0f]},lore=[{"text":"✦ 超限石","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"适用于 ","color":"gray"},{"text":"枢","color":"blue"},{"text":"   ·   ","color":"dark_gray"},{"text":"前置 ","color":"gray"},{"text":"尚未超限","color":"aqua"}]},{"text":" ","italic":false},{"text":"敲入后枢更名为「超限·枢」，自身魔力值","color":"gray","italic":false},{"text":"上限 +160 。自身术阵位上限 +1 。自身","color":"gray","italic":false},{"text":"召唤术阵时，自身恢复 1% 生命值。自身","color":"gray","italic":false},{"text":"保持满血量 12 秒后，进入「阵成」，持","color":"gray","italic":false},{"text":"续 8 秒（可以和套装及承的「阵成」加算","color":"gray","italic":false},{"text":"叠加），冷却 12 秒。套装的「阵成」的","color":"gray","italic":false},{"text":"冷却时间 -4 秒。","color":"gray","italic":false}],custom_data={zx:["ol_pivot"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"}]
