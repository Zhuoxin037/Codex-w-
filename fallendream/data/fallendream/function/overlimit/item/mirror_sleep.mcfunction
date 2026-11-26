# ============================================================
# fallendream:overlimit/item/mirror_sleep —— 给一块「超限·镜寐」
# 【接线】custom_data zx:["ol_mirror_sleep"] 供 advancement 识别；
#   CMD=101 与 _gen_stone_icons.py 的 CMD 表、recovery_compass.json 路由三处一致。
# 【敲入】副手持对应装备 + 主手右键本石 -> consume_item -> apply/mirror_sleep。
#   三件套(item/advancement/apply)与 oldef 均已就位，敲失败退材料。
# ============================================================

give @s recovery_compass[max_stack_size=1,item_name={text:"超限·镜寐",bold:true,color:light_purple},custom_model_data={floats:[101.0f]},lore=[{"text":"✦ 超限石","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"适用于 ","color":"gray"},{"text":"镜寐","color":"blue"},{"text":"   ·   ","color":"dark_gray"},{"text":"前置 ","color":"gray"},{"text":"尚未超限","color":"aqua"}]},{"text":" ","italic":false},{"text":"敲入后镜寐更名为「超限·镜寐」，自身魔","color":"gray","italic":false},{"text":"力值上限 +150。自身每攻击 3 次生物后，","color":"gray","italic":false},{"text":"若自身魔力足够，则消耗 30 魔力并对下","color":"gray","italic":false},{"text":"一个攻击且未附有「白昼梦」的生物附加","color":"gray","italic":false},{"text":"「白昼梦」。本次附加的「白昼梦」若被","color":"gray","italic":false},{"text":"消耗则使被消耗的生物的 3 格内的其他生","color":"gray","italic":false},{"text":"物被附加一次持续 8 秒的「白昼梦」，之","color":"gray","italic":false},{"text":"后使自身恢复 1% 魔力值。","color":"gray","italic":false}],custom_data={zx:["ol_mirror_sleep"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"}]
