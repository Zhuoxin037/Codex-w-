# ============================================================
# fallendream:overlimit/item/cross_dream —— 给一块「超限·渡梦」
# 【接线】custom_data zx:["ol_cross_dream"] 供 advancement 识别；
#   CMD=107 与 _gen_stone_icons.py 的 CMD 表、recovery_compass.json 路由三处一致。
# 【敲入】副手持对应装备 + 主手右键本石 -> consume_item -> apply/cross_dream。
#   三件套(item/advancement/apply)与 oldef 均已就位，敲失败退材料。
# ============================================================

give @s recovery_compass[max_stack_size=1,item_name={text:"超限·渡梦",bold:true,color:light_purple},custom_model_data={floats:[107.0f]},lore=[{"text":"✦ 超限石","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"适用于 ","color":"gray"},{"text":"渡梦","color":"blue"},{"text":"   ·   ","color":"dark_gray"},{"text":"前置 ","color":"gray"},{"text":"尚未超限","color":"aqua"}]},{"text":" ","italic":false},{"text":"敲入后渡梦更名为「超限·渡梦」，自身魔","color":"gray","italic":false},{"text":"力值上限 +160。受到附有「白昼梦」的生","color":"gray","italic":false},{"text":"物造成的近战伤害后，若其仍存活且在自","color":"gray","italic":false},{"text":"身 3 格内，则消耗其「白昼梦」，使自身","color":"gray","italic":false},{"text":"沿视线反方向水平后撤最多 1.5 格，并获","color":"gray","italic":false},{"text":"得 5 秒迅捷Ⅲ，遇到障碍即停。之后自身","color":"gray","italic":false},{"text":"获得相当于最大生命值 20% 的临时生命值，","color":"gray","italic":false},{"text":"持续 15 秒。后撤终点 3 格内若附有","color":"gray","italic":false},{"text":"「白昼梦」的生物则使其时停 1 秒，每影","color":"gray","italic":false},{"text":"响一个生物，则自身恢复 12 魔力。该效","color":"gray","italic":false},{"text":"果 6 秒内不可再次触发。","color":"gray","italic":false}],custom_data={zx:["ol_cross_dream"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"}]
