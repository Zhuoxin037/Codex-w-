# ============================================================
# fallendream:overlimit/item/flesh_mill —— 给一块「超限·血肉磨坊」
# 【接线】custom_data zx:["ol_flesh_mill"] 供 advancement 识别；
#   CMD=113 与 _gen_stone_icons.py 的 CMD 表、recovery_compass.json 路由三处一致。
# 【敲入】副手持对应装备 + 主手右键本石 -> consume_item -> apply/flesh_mill。
#   三件套(item/advancement/apply)与 oldef 均已就位，敲失败退材料。
# ============================================================

give @s recovery_compass[max_stack_size=1,item_name={text:"超限·血肉磨坊",bold:true,color:light_purple},custom_model_data={floats:[113.0f]},lore=[{"text":"✦ 超限石","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"适用于 ","color":"gray"},{"text":"血肉磨坊","color":"blue"},{"text":"   ·   ","color":"dark_gray"},{"text":"前置 ","color":"gray"},{"text":"尚未超限","color":"aqua"}]},{"text":" ","italic":false},{"text":"敲入后血肉磨坊更名为「超限·血肉磨坊」，","color":"gray","italic":false},{"text":"穿戴时，自身受到伤害后则每秒获得 3 魔","color":"gray","italic":false},{"text":"力值及再生Ⅱ效果，持续 5 秒。上述效果","color":"gray","italic":false},{"text":"持续期间再次受到伤害时，立即恢复本轮","color":"gray","italic":false},{"text":"尚未结算的额外魔力值并恢复 1% 生命值，","color":"gray","italic":false},{"text":"随后重新开始该效果。","color":"gray","italic":false}],custom_data={zx:["ol_flesh_mill"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"}]
